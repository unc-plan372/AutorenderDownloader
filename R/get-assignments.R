#' Get list of students who have started the assignment
#' @export
get_students_started = function (assignment_id) {
    req = authenticated_request(glue("https://api.github.com/assignments/{assignment_id}/accepted_assignments"))
    req_perform(req) |>
        resp_body_json()
}

#' Get assignments for a classroom
#' GH_TOKEN must be allowed access to content
get_assignments = function (classroom_id) {
    req = authenticated_request(glue("https://api.github.com/classrooms/{classroom_id}/assignments"))
    req_perform(req) |>
        resp_body_json()
}

#' Get all classrooms available to the user
get_classrooms = function () {
    req = authenticated_request(glue("https://api.github.com/classrooms"))
    req_perform(req) |>
        resp_body_json()
}

#' List the artifacts for a repo (should be username/repo format)
get_artifacts = function (repo) {
    resp = authenticated_request(glue("https://api.github.com/repos/{repo}/actions/artifacts")) |>
        req_url_query("per_page"=100) |>
        req_perform()

    # check for pagination (should only happen with >100 commits, unlikely)
    if (resp_header_exists(resp, "Link")) {
        print("Warning: for repo {repo}, more than 100 artifacts; may not be retrieving latest")
    }

    json = resp_body_json(resp)

    map(json$artifacts, function (a) {
        tibble(created_at=a$created_at, url=a$archive_download_url)
    }) |>
        list_rbind() |>
        mutate(created_at = ymd_hms(created_at))

}

download_artifact = function (url, outfile) {
    # TODO loading whole ZIP file to memory
    zip = authenticated_request(url) |>
        req_perform() |>
        resp_body_raw()

    writeBin(zip, outfile)
}

get_all_artifacts_for_assigment = function (assignment_id, output_directory, order="alphabetical") {
    dir.create(output_directory)
    dir.create(file.path(output_directory, "student_work"))
    
    students = get_students_started(assignment_id)

    links = map(students, function (assg, order="alphabetical") {
        login = assg$students[[1]]$login |> str_replace_all("[^a-zA-Z0-9_]+", "-")
        # https://xkcd.com/327/
        name = htmlEscape(assg$students[[1]]$name)
        repo = assg$repository$full_name

        student_dir = file.path(output_directory, "student_work", login)
        dir.create(student_dir)

        zipfile = file.path(student_dir, "artifact.zip")

        artifact = get_artifacts(repo) |>
            slice_max(created_at) |>
            pull(url)

        download_artifact(artifact, zipfile)

        unzip(zipfile, exdir=student_dir)
        file.remove(zipfile)

        tibble(
            name = name,
            href = glue("student_work/{login}/analysis.html")
        )
    }) |>
        list_rbind()

    conn = file(file.path(output_directory, "index.html"))
    header = "
    <!DOCTYPE html>
    <html>
        <head>
            <title>Assignment results</title>
        </head>
        <body>
            <ul>
    "

    if (order == "random") {
        links$idx = runif(nrow(links))
        links = arrange(links, idx)
    } else if (order == "alphabetical") {
        links = arrange(links, name)
    }

    links = glue('<a href="{links$href}">{links$name}</a>')

    footer = "</ul></body></html>"
    
    cat(header, links, footer, file=file.path(output_directory, "index.html"))
}