# Autorender Downloader

This forms part of an R/Quarto workflow for student assignments through Github Classroom. This allows students to commit their analysis to a Github Classroom assignment, Github Actions will render it automatically, and then the instructor can
download all of the assignments.

## For instructors: creating the assignment

In your Github Classroom, create a new assignment. On the second page, set the template to `unc-plan372/autorender-action`. Since this is a public template, Github Classroom will default to assignment repositories being public, I recommend changing this to private. On the third page, I also recommend adding `.github/**/*` as a protected path, to ensure the autorender code is not modified by students.

## For students: submitting assignments

Use the invite link to accept an assignment. This will create a repository on Github for your assignment, and after clicking through a few prompts will take you there. Clone the repository to your computer,
and do your work there.

All of your analysis will need to be put in the file called `analysis.qmd` (make sure you also fill
out your name in that file) and committed to the repository. You will also need to commit the
data file to the repository. In the file, please note which question each output answers.

When you push to Github, your Quarto document will be rendered
automatically. You can tell if this worked by opening the assignment page on Github and looking at the most
recent commit at the top (which should be the most recent commit you created). There will be an icon
next to the commit message:

- If you see a yellow circle, rendering is in progress - check back in a few minutes.
- If you see a green check mark, rendering was successful. You can view the rendered file by clicking the
    "Actions" tab, then the name of your most recent commit. Under artifacts at the bottom of the page,
    there will be a file called "analysis"; clicking on that will download a ZIP file that contains
    your rendered file. You can open this on your computer to see what Github rendered and ensure
    it is what you intended.
- If you see a red X, rendering was not successful. You can see what the error was by clicking the
    red X and scrolling through the page to find the error. It should be under the "Render" section—
    if it is somewhere else, this is most likely an issue with Github rather than your code, let me
    know so I can troubleshoot. If it is under the Render section, look at the error message, fix it
    in your code, and then push again.

Once you are happy with the Github rendered results, you are done - pushing your code to Github is 
also how you submit the assignment.

## For instructors: grading

Load the package in this repository, either by installing the repository:

```
devtools::install_github("unc-plan372/AutorenderDownloader")
```

or by cloning it and, opening it in RStudio/VSCode.

You will need to create a Github fine-grained access token in the organization that owns your classroom, with access to all repositories, with read-only access to content and actions. This needs to be in the GH_TOKEN environment variable. If you took option 2, you can create a `.Renviron` file to hold this token. If you took option 1, set the environment variable the normal way, or run `Sys.setenv(GH_TOKEN="YOUR TOKEN")` before running the downloader.

If you used `devtools::install_github()`, run `library(AutorenderDownloader)` to load the library. If you cloned and opened in RStudio/VSCode, run `devtools::load_all()`. Then, to download all submitted assignments, run:

```
autorender_download()
```

and follow the prompts.

By default students will be listed in alphabetical order. Use

```
autorender_download(order="random")
```

to get them in random (but stable within an assignment) order.