authenticated_request = function (...) {
    token = Sys.getenv("GH_TOKEN")

    request(...) |>
        req_headers(
            "Authorization" = glue("Bearer {token}"),
            "Accept" = "application/vnd.github+json",
            "X-GitHub-Api-Version" = "2022-11-28"
        )
}