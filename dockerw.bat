@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      dev               Start Developer service.
    echo      convert           Convert notebook to python
    echo      run               Start Runtime service
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "dev" mathod -------------------

:cli-dev (
    IF NOT defined OPEN_NOTEBOOK_ONLY (
        echo ^> Build image
        docker build --rm^
            -t python.dev:%PROJECT_NAME%^
            ./docker/develop
        echo ^> Startup docker container instance
        docker rm -f python-dev-%PROJECT_NAME%
        docker run -d --rm -p 8888:8888^
            -v %cd%/src:/home/jovyan/code^
            --name python-dev-%PROJECT_NAME%^
            python.dev:%PROJECT_NAME%
        echo ^> Waiting 5s for server startup
        docker exec python-dev-%PROJECT_NAME% mkdir img
        TIMEOUT /T 5 >nul
    )
    echo ^> Start chrome with incognito mode
    docker exec -ti python-dev-%PROJECT_NAME% bash -l -c "jupyter notebook list --json | jshon -e token | cut -c 2- | rev | cut -c 2- | rev" > .tmp
    set /p JUPYTER_TOKEN=<.tmp
    del .tmp
    start chrome --incognito http://localhost:8888/?token=%JUPYTER_TOKEN%
    echo ^> If you need re-open notebook, use 'dockerw dev --open'
    goto end
)

:cli-dev-args (
    for %%p in (%*) do (
        if "%%p"=="--open" ( set OPEN_NOTEBOOK_ONLY=1 )
    )
    goto end
)

:cli-dev-help (
    echo Start service & jupyter in chrome.
    echo.
    echo Options:
    echo      --open            Open notebook and don't restart server.
    echo.
    goto end
)

:: ------------------- Command "convert" mathod -------------------

:cli-convert (
    echo ^> Convert *.ipynb to *.py
    docker exec -ti python-dev-%PROJECT_NAME% bash -l -c "cd code && ipython nbconvert --to python *.ipynb"
    goto end
)

:cli-convert-args (
    goto end
)

:cli-convert-help (
    echo Convert notebook to python.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "run" mathod -------------------

:cli-run-prepare (
    echo ^> Initial cache
    IF NOT EXIST cache\img (
        mkdir cache\img
    )

    echo ^> Build image
    docker build --rm^
        -t python.run:%PROJECT_NAME%^
        ./docker/runtime

    goto end
)

:cli-run (
    call :cli-run-prepare

    echo ^> Startup docker container instance
    set PYTHON_FILE=%CLI_DIRECTORY%src\!EXEC_TARGET: =!.py
    IF EXIST !PYTHON_FILE! (
        docker run -ti --rm^
            -v %cd%/src:/repo^
            -v %cd%/cache/img:/img^
            --name python-run-%PROJECT_NAME%^
            python.run:%PROJECT_NAME% /repo/!EXEC_TARGET: =!.py
    ) else (
        IF NOT %EXEC_TARGET% == null (
            echo ^> File !PYTHON_FILE! not find.
        )
        echo ^> Python file int directory "src" :
        dir /B %CLI_DIRECTORY%src\*.py
    )

    goto end
)

:cli-run-args (
    set EXEC_TARGET=null
    for %%p in (%*) do (
        echo %%p | findstr /r "\=" >nul 2>&1
        if errorlevel 1 (
            @rem not assign value.
            if "%%p"=="--exec" ( set EXEC_TARGET=null )
        ) else (
            @rem has assign value.
            for /F "tokens=1,2 delims==" %%G in (%%p) do (
               if "%%G"=="--exec" ( set EXEC_TARGET=%%H )
            )
        )
    )
    goto end
)

:cli-run-help (
    echo Start Runtime service and execute python file.
    echo.
    echo Options:
    echo      --exec            Target python file.
    echo.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
