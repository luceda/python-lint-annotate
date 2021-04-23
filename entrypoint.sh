#!/bin/sh -l

# Parameters
#
# $1 - python-root-list
# $2 - use-pylint
# $3 - use-pycodestyle
# $4 - use-flake8
# $5 - use-black
# $6 - use-mypy
# $7 - use-isort
# $8 - use-vulture
# $9 - use-pydocstyle
# ${10} - extra-pylint-options
# ${11} - extra-pycodestyle-options
# ${12} - extra-flake8-options
# ${13} - extra-black-options
# ${14} - extra-mypy-options
# ${15} - extra-isort-options
# ${16} - extra-vulture-options
# ${17} - extra-pydocstyle-options

echo python-root-list:          $1  # useless now, replaced by $new_python_files_in_branch
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

find_base_commit

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
if [[ $new_files_in_branch =~ .*".py".* ]]; then
    new_python_files_in_branch=$(
        git diff \
            --name-only \
            --diff-filter=AM \
            "$BASE_COMMIT" | grep '\.py$' | grep 'python3' | tr '\n' ' '
    )
    echo "New python3 files in branch: $new_python_files_in_branch"
fi


if [ "$2" = true ] ; then

    echo Running: pylint ${10} $new_python_files_in_branch

    $CONDA/bin/pylint --output-format="colorized" ${10} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Pylint ok"
    else
        echo "Pylint error"
    fi

fi

if [ "$3" = true ] ; then

    echo Running: pycodestyle ${11} $new_python_files_in_branch

    $CONDA/bin/pycodestyle ${11} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "pycodestyle ok"
    else
        echo "pycodestyle error"
    fi

fi

if [ "$4" = true ] ; then

    echo Running: flake8 ${12} $new_python_files_in_branch

    $CONDA/bin/flake8 ${12} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Flake8 ok"
    else
        echo "Flake8 error"
    fi

fi

if [ "$5" = true ] ; then

    echo Running: black --check ${13} $new_python_files_in_branch

    $CONDA/bin/black --check ${13} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Black ok"
    else
        echo "Black error"
    fi

fi

if [ "$6" = true ] ; then

    echo Running: mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $new_python_files_in_branch

    $CONDA/bin/mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "mypy ok"
    else
        echo "mypy error"
    fi

fi

if [ "$7" = true ] ; then

    echo Running: isort ${15} $new_python_files_in_branch -c --diff

    $CONDA/bin/isort ${15} $new_python_files_in_branch -c --diff
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "isort ok"
    else
        echo "isort error"
    fi

fi

if [ "$8" = true ] ; then

    echo Running: vulture ${16} $new_python_files_in_branch

    $CONDA/bin/vulture ${16} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "vulture ok"
    else
        echo "vulture error"
    fi

fi

if [ "$9" = true ] ; then

    echo Running: pydocstyle ${17} $new_python_files_in_branch

    $CONDA/bin/pydocstyle ${17} $new_python_files_in_branch
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "pycodestyle ok"
    else
        echo "pycodestyle error"
    fi

fi
