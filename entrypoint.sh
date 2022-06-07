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

echo python-root-list:          $1
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

if [ "$2" = true ] ; then

    echo Running: pylint ${10} $1

    pylint --output-format="colorized" ${10} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Pylint ok"
    else
        echo "Pylint error"
    fi

fi

if [ "$3" = true ] ; then

    echo Running: pycodestyle ${11} $1

    pycodestyle ${11} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "pycodestyle ok"
    else
        echo "pycodestyle error"
    fi

fi

if [ "$4" = true ] ; then

    echo Running: flake8 ${12} $1

    flake8 ${12} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Flake8 ok"
    else
        echo "Flake8 error"
    fi

fi

if [ "$5" = true ] ; then

    echo Running: black --check ${13} $1

    black --check ${13} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "Black ok"
    else
        echo "Black error"
    fi

fi

if [ "$6" = true ] ; then

    echo Running: mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $1

    mypy --ignore-missing-imports --follow-imports=silent --show-column-numbers ${14} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "mypy ok"
    else
        echo "mypy error"
    fi

fi

if [ "$7" = true ] ; then

    echo Running: isort ${15} $1 -c --diff

    isort ${15} $1 -c --diff
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "isort ok"
    else
        echo "isort error"
    fi

fi

if [ "$8" = true ] ; then

    echo Running: vulture ${16} $1

    vulture ${16} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "vulture ok"
    else
        echo "vulture error"
    fi

fi

if [ "$9" = true ] ; then

    echo Running: pydocstyle ${17} $1

    pydocstyle ${17} $1
    exit_code=$?

    if [ "$exit_code" = "0" ]; then
        echo "pycodestyle ok"
    else
        echo "pycodestyle error"
    fi

fi
