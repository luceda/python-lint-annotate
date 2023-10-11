#!/bin/bash

# treat unset variables as error
set -u
# if any command in a pipe fails, fail
set -o pipefail
# print all debug information
set -x

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

find_base_commit() {
    BASE_COMMIT=$(
        jq \
            --raw-output \
            .pull_request.base.sha \
            "$GITHUB_EVENT_PATH"
    )
    # If this is not a pull request action it can be a check suite re-requested
    if [ "$BASE_COMMIT" == null ]; then
        BASE_COMMIT=$(
            jq \
                --raw-output \
                .check_suite.pull_requests[0].base.sha \
                "$GITHUB_EVENT_PATH"
        )
    fi
}

ACTION=$(
    jq --raw-output .action "$GITHUB_EVENT_PATH"
)
# First 2 actions are for pull requests, last 2 are for check suites.
ENABLED_ACTIONS='synchronize opened requested rerequested'

main() {

    echo python3-root-folder:       $1
    echo use-pylint:                $2
    echo use-pycodestyle:           $3
    echo use-flake8:                $4
    echo use-black:                 $5
    echo use-mypy:                  $6
    echo use-isort:                 $7
    echo use-vulture:               $8
    echo use-pydocstyle             $9
    echo extra-pylint-options:      ${10}
    echo extra-pycodestyle-options: ${11}
    echo extra-flake8-options:      ${12}
    echo extra-black-options:       ${13}
    echo extra-mypy-options:        ${14}
    echo extra-isort-options:       ${15}
    echo extra-vulture-options:     ${16}
    echo extra-pydocstyle-options:  ${17}

    # actions path has the copy of this actions repo
    for matcher in $GITHUB_ACTION_PATH/matchers/*.json
    do
        echo adding matcher $matcher
        echo "::add-matcher::${matcher}"
    done
    echo "TERM: changing from $TERM -> xterm"
    export TERM=xterm


    if [[ $ENABLED_ACTIONS != *"$ACTION"* ]]; then
        echo -e "Not interested in this event: $ACTION.\nExiting..."
        exit
    fi

    find_base_commit

    echo "BASE_COMMIT:"
    echo $BASE_COMMIT

    git fetch origin $BASE_COMMIT

    # Find adjusted files in PR:
    new_files_in_branch=$(
        git diff \
            --name-only \
            --diff-filter=AM \
            "$BASE_COMMIT"
    )
    new_files_in_branch1=$(echo $new_files_in_branch | tr '\n' ' ')

    echo "New files in branch: $new_files_in_branch1"
    # Feed to flake8 which will return the output in json format.
    # shellcheck disable=SC2086

    n_errors=0

    if [[ $new_files_in_branch =~ .*".py".* ]]; then
        pattern=$(echo $1 | tr -s ' ' '\|')
        new_python_files_in_branch=$(
            echo "$new_files_in_branch" | grep -E '\.py$' | grep -E "${pattern}"
        )
        echo "New $1 files in branch: $new_python_files_in_branch"
    else
      new_python_files_in_branch=""
      echo "No new $1 files in branch"
    fi

    if [[ $new_python_files_in_branch =~ .*".py".* ]]; then
        if [ "$2" = true ] ; then

            echo Running: pylint ${10} $new_python_files_in_branch

            pylint --output-format="colorized" ${10} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "Pylint ok"
            else
                echo "Pylint error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$3" = true ] ; then

            echo Running: pycodestyle ${11} $new_python_files_in_branch

            pycodestyle ${11} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "pycodestyle ok"
            else
                echo "pycodestyle error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$4" = true ] ; then

            echo Running: flake8 ${12} $new_python_files_in_branch
            flake8 ${12} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "Flake8 ok"
            else
                echo "Flake8 error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$5" = true ] ; then

            echo Running: black --check --verbose ${13} $new_python_files_in_branch

            black --check --verbose ${13} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "Black ok"
            else
                echo "Black error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$6" = true ] ; then

            echo Running: mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $new_python_files_in_branch
            mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "mypy ok"
            else
                echo "mypy error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$7" = true ] ; then

            echo Running: isort ${15} $new_python_files_in_branch -c --diff

            isort ${15} $new_python_files_in_branch -c --diff
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "isort ok"
            else
                echo "isort error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$8" = true ] ; then

            echo Running: vulture ${16} $new_python_files_in_branch

            vulture ${16} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "vulture ok"
            else
                echo "vulture error"
                n_errors=$((n_errors+1))
            fi

        fi

        if [ "$9" = true ] ; then

            echo Running: pydocstyle ${17} $new_python_files_in_branch

            pydocstyle ${17} $new_python_files_in_branch
            exit_code=$?

            if [ "$exit_code" = "0" ]; then
                echo "pycodestyle ok"
            else
                echo "pycodestyle error"
                n_errors=$((n_errors+1))
            fi

        fi

    fi

    if [ "$n_errors" -gt 0 ]; then
        echo "$n_errors error(s) in total. Please fix them before merging this pull request."
        exit 1
    fi
}

main "$@"
