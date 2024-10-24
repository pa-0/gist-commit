# Getting the Gist of GitHub Actions

_Tutorial and tips for GitHub Actions workflows_

[![Mentioned in Awesome Actions](https://awesome.re/mentioned-badge-flat.svg)](https://github.com/sdras/awesome-actions)

## Table of Contents <!-- omit in toc -->

- [Introduction](#introduction)
- [Workflows and actions](#workflows-and-actions)
  - [Getting started](#getting-started)
  - [Example workflow with one job](#example-workflow-with-one-job)
  - [Example workflow with a build matrix](#example-workflow-with-a-build-matrix)
  - [Output](#output)
- [Pro tips](#pro-tips)
  - [General](#general)
  - [Secrets](#secrets)
  - [Containers](#containers)
  - [Concurrency](#concurrency)
  - [Chaining workflows together](#chaining-workflows-together)
  - [Error handling](#error-handling)
  - [Environments](#environments)
  - [VMs and pricing](#vms-and-pricing)
  - [GitHub Actions and Poetry](#github-actions-and-poetry)
- [Challenges](#challenges)
  - [Lacking necessary `on:` triggers](#lacking-necessary-on-triggers)
  - [PR merge conflicts blocking workflow runs](#pr-merge-conflicts-blocking-workflow-runs)
  - [Understanding context and expression syntax](#understanding-context-and-expression-syntax)
- [Resources](#resources)

## Introduction

[GitHub Actions](https://github.com/features/actions) is a [CI/CD](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) service that runs on GitHub repos.

Compared with Travis CI, GitHub Actions is:

- **Easier**
- **More flexible**
- **More powerful**
- **More secure**

## Workflows and actions

### Getting started

- **[Workflows](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)** are YAML files stored in the _.github/workflows_ directory of a repository.
- An **[Action](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)** is a package you can import and use in your **workflow**. GitHub provides an **[Actions Marketplace](https://github.com/marketplace?type=actions)** to find actions to use in workflows.
- A **job** is a virtual machine that runs a series of **steps**. **Jobs** are parallelized by default, but **steps** are sequential by default.
- **To [get started](https://docs.github.com/en/actions/getting-started-with-github-actions):**
  - Navigate to one of your repos
  - Click the "Actions" tab.
  - Select "New workflow"
  - Choose one of the starter workflows. These templates come from [actions/starter-workflows](https://github.com/actions/starter-workflows).
- Workflows can be [triggered](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows) by many different events from the GitHub API. The `workflow_dispatch` trigger allows workflows to be triggered manually, with optional input values that can be referenced in the workflow.
- GitHub provides an [expression syntax](https://docs.github.com/en/actions/learn-github-actions/contexts) for programmatic control of workflows. For example:
  ```text
  echo "SPAM_STRING=${{ format(
    'Spam is short for {0} and is made from {1} by {2}',
    'spiced ham',
    'pork shoulder',
    'Hormel'
  ) }}" >>"$GITHUB_OUTPUT"
  ```
  - Command: `echo "ENV_NAME=value" >>"$GITHUB_OUTPUT"`, like `echo "COLOR=green" >>"$GITHUB_OUTPUT"`
  - Expression: `${{ }}`
  - Function:
    - `contains('this is a demo', 'demo')` evaluates to Boolean `true`
    - `format('Spam is short for {0} and is made from {1} by {2}', 'spiced ham', 'pork shoulder', 'Hormel')`

### Example workflow with one job

A workflow file might look like this:

```yml
name: demo

on:
  push:
    branches: [demo]
  pull_request:
  workflow_dispatch:

env:
  APP_NAME: "GitHub Actions demo workflow"

jobs:
  simple:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@main
      - name: Verify the workspace context
        run: echo 'Workspace directory is ${{ github.workspace }}'
      - name: Run a simple echo command with a pre-set environment variable
        run: echo 'Hello World, from ${{ env.APP_NAME }}'
      - name: Set an environment variable using a multi-line string
        run: |
          echo "MULTI_LINE_STRING<<EOF" >>"$GITHUB_ENV"
          echo "
            Hello World!
            Here's a
            multi-line string.
          " >>"$GITHUB_ENV"
          echo "EOF" >>"$GITHUB_ENV"
      - name: Check the environment variable from the previous step
        run: echo $MULTI_LINE_STRING
      - name: Set build environment based on Git branch name
        if: github.ref == 'refs/heads/demo' || contains(env.APP_NAME, 'demo')
        run: echo "BUILD_ENV=demo" >>"$GITHUB_ENV"
      - name: Use the GitHub Actions format function to provide some details about Spam
        run: |
          echo "SPAM_STRING=${{ format(
            'Spam is short for {0} and is made from {1} by {2}',
            'spiced ham',
            'pork shoulder',
            'Hormel'
          ) }}" >>"$GITHUB_ENV"
      - name: Run a multi-line shell script block
        run: |
          echo "
          Hello World, from ${{ env.APP_NAME }}!
          Add other actions to build,
          test, and deploy your project.
          "
          if [ "$BUILD_ENV" = "demo" ] || ${{ contains(env.APP_NAME, 'demo') }}; then
            echo "This is a demo."
          elif [ "$BUILD_ENV" ]; then
            echo "BUILD_ENV=$BUILD_ENV"
          else
            echo "There isn't a BUILD_ENV variable set."
          fi
          echo "Did you know that $SPAM_STRING?"
      - uses: actions/setup-python@main
        with:
          python-version: "3.10"
      - name: Run a multi-line Python script block
        shell: python
        run: |
          import os
          import sys

          version = f"{sys.version_info.major}.{sys.version_info.minor}"
          print(f"Hello World, from Python {version} and ${{ env.APP_NAME }}!")
          print(f"Did you know that {os.getenv('SPAM_STRING', 'there is a SPAM_STRING')}?")
      - name: Run an external shell script
        working-directory: ./.github/workflows
        run: . github-actions-workflow-demo.sh
      - name: Run an external Python script
        working-directory: ./.github/workflows
        run: python github-actions-workflow-demo.py
```

### Example workflow with a build matrix

<img src="https://gist.githubusercontent.com/br3ndonland/f9c753eb27381f97336aa21b8d932be6/raw/11a9ebb7b848aa016deaed4187541fd49fb30e21/images-features-matrix.png" alt="GitHub Actions Build Matrix from https://github.com/features/actions" width="800px">

```yml
name: demo

on:
  push:
    branches: [master, develop]
  pull_request:
  workflow_dispatch:

env:
  APP_NAME: "GitHub Actions sample workflow with build matrix"

jobs:
  matrix:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macOS-latest, ubuntu-latest, windows-latest]
        python-version: ["3.8", "3.9", "3.10"]
        silly-word: [foo, bar, baz]
    steps:
      - uses: actions/checkout@main
      - name: Echo a silly word
        run: echo ${{ matrix.silly-word }}
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@main
        with:
          python-version: ${{ matrix.python-version }}
      - name: Run a multi-line Python script block
        shell: python
        run: |
          import os
          import sys

          version = f"{sys.version_info.major}.{sys.version_info.minor}"
          print(f"Hello World, from Python {version}, ${{ matrix.os }}, and ${{ matrix.silly-word }}!")
```

### Output

GitHub Actions provides output like this:

<img src="https://gist.githubusercontent.com/br3ndonland/f9c753eb27381f97336aa21b8d932be6/raw/3315059cbe4dad063328daf58f85ab1e7949eac9/images-annotated-workflow.png" alt="Annotated workflow image from https://docs.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow" width="800px">

You can see a demo workflow in [br3ndonland/algorithms](https://github.com/br3ndonland/algorithms/actions/workflows/demo.yml).

## Pro tips

### General

- **Steps** in a **job** are sequential by default.
- **Jobs** are parallelized by default, unless you control the order by using `needs`.
- **Action inputs and outputs**: If you're unclear on what you can do with an action, navigate to the GitHub repo for the action and look for a file called _action.yml_, like [this one in actions/checkout](https://github.com/actions/checkout/blob/main/action.yml). This file is a manifest declaring what the action can do.
- **Debugging**: If you want more debugging information, add `ACTIONS_STEP_DEBUG` to your secrets parameter store.
  - Key: `ACTIONS_STEP_DEBUG`
  - Value: `true`

### Secrets

**Secrets** is an encrypted parameter store (key:value store). The syntax is similar to environment variables.

- [GitHub Actions can use secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets), so you don't have to hard-code API keys and other credentials. Secrets are redacted from GitHub Actions logs.
- Each repo has a secrets store at _Settings -> Secrets_ (`https://github.com/org/repo/settings/secrets`)
- Each organization also has a secrets store that can be used in all the organization's repos.
- Every workflow job offers [automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication).
  - The token is stored as `secrets.GITHUB_TOKEN`.
  - The `permissions:` key can be used to alter the permissions granted to the token.
  - In order to use the token with the GitHub CLI (installed automatically on [GitHub Actions runner images](https://github.com/actions/runner-images)), an environment variable should be set with `GH_TOKEN` as the name and `secrets.GITHUB_TOKEN` as the value.

### Containers

- [Service containers](https://docs.github.com/en/actions/using-containerized-services/about-service-containers) can be set up for test databases and other needs.
- [GitHub Actions now allows service containers from private registries](https://github.blog/changelog/2020-09-24-github-actions-private-registry-support-for-job-and-service-containers/).
- Users can create their own actions. For example, [container actions](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action) can run in Docker containers of your choosing. [Action composition](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) can help reduce code duplication.

### Concurrency

- GitHub Actions offers a [`concurrency`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency) key to control how many workflows are running at one time.
- Syntax examples:
  - To only allow one concurrent workflow per commit: `concurrency: ci-${{ github.ref }}`
  - To only allow one concurrent workflow per [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment), at the job level: `concurrency: ${{ environment.name }}`
- Concurrency can be specified at the workflow level, or at the job level.
  - It's most useful to specify concurrency at the job level, because outputs from earlier jobs in the workflow can be used (like `concurrency: ${{ needs.setup-job.outputs.ecs-deployment-group-name }}`). Unfortunately, job-level concurrency ([`jobs.<job_id>.concurrency`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idconcurrency)) triggers runs out of order (earlier jobs run after later jobs), which is not very useful. The docs explain, "Note: When concurrency is specified at the job level, order is not guaranteed for jobs or runs that queue within 5 minutes of each other."
  - Concurrency can also be specified at the workflow level, using the name of the workflow (`concurrency: ${{ github.workflow }}`). This avoids triggering runs out of order, but could also result in canceled workflow runs. Only one run can be pending at a time, and each new run will cancel the previous pending run.
- A common use case for limiting concurrency is in deployments. For example, when deploying Docker containers to AWS ECS Fargate with CodeDeploy, the [aws-actions/amazon-ecs-deploy-task-definition](https://github.com/marketplace/actions/amazon-ecs-deploy-task-definition-action-for-github-actions) step may error with [`DeploymentLimitExceededException`](https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_CreateDeployment.html). The error message will look something like, "The Deployment Group already has an active Deployment." Furthermore, if GitHub Actions workflows are canceled, the ECS Fargate CodeDeploy deployments are not necessarily also canceled. If another GitHub Actions run proceeds, the `DeploymentLimitExceededException` may still be seen.
  - One solution is to add the `force-new-deployment: true` setting to the [aws-actions/amazon-ecs-deploy-task-definition](https://github.com/marketplace/actions/amazon-ecs-deploy-task-definition-action-for-github-actions) step, to ensure that a new deployment is triggered.
  - It is possible to simply re-run any workflows that failed because of this error.
  - It could also be helpful to limit concurrency to a single deployment to avoid errors.
- Overall, GitHub Actions concurrency has many limitations, and may not be useful at this point.
- _Note: concurrency is in beta and the syntax may change._

### Chaining workflows together

The `needs:` key helps chain _jobs within a workflow_ together, but not _multiple workflows_. There are a few other strategies for chaining workflows together.

#### `workflow_run`

There's a `workflow_run` trigger that allows one workflow to trigger another. The [GitHub Actions docs](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_run) explain how to use it to chain workflows:

> To run a workflow job conditionally based on the result of the previous workflow run, you can use the [`jobs.<job_id>.if`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idif) or [`jobs.<job_id>.steps[*].if`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsif) conditional combined with the `conclusion` of the previous run. For example:
>
> ```yml
> on:
>   workflow_run:
>     workflows: ["Build"]
>     types: [completed]
>
> jobs:
>   on-success:
>     runs-on: ubuntu-latest
>     if: github.event.workflow_run.conclusion == 'success'
>     steps: ...
>   on-failure:
>     runs-on: ubuntu-latest
>     if: github.event.workflow_run.conclusion == 'failure'
>     steps: ...
> ```

#### `gh workflow run`

The GitHub CLI has a `gh workflow run` command for triggering workflows with `workflow_dispatch` events. The command can be used within a GitHub Actions job in one workflow to trigger another workflow (as long as the workflow being triggered includes `on: workflow_dispatch`).

As mentioned in the [secrets section](#secrets), every workflow job offers [automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication) with `secrets.GITHUB_TOKEN`. In order to use the token with the GitHub CLI (installed automatically on [GitHub Actions runner images](https://github.com/actions/runner-images)), an environment variable should be set with `GH_TOKEN` as the name and `secrets.GITHUB_TOKEN` as the value. Adjust token `permissions:` based on how the GitHub CLI will be used.

```yml
name: Trigger another workflow

on:
  workflow_dispatch:

jobs:
  trigger-workflow:
    runs-on: ubuntu-latest
    permissions:
      actions: write
      contents: read
    steps:
      - run: gh workflow run WORKFLOW_NAME --ref ${{ github.ref }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Reusable workflows

GitHub has also introduced some features for [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows), including a new `workflow_call` trigger that allows entire workflows to be called directly. The called workflow must include `on: workflow_call`, with inputs that are referenced in the downstream workflow.

```yml
# greeter.yml
name: Reusable workflow example

on:
  workflow_call:
    inputs:
      username:
        description: Username for the workflow
        required: true
        type: string
      repo:
        description: >
          Repository to check out.
          Include a personal access token (PAT) with repo scope for private repos.
        required: true
        type: string
      environment:
        required: false
        type: string
        default: development
    secrets:
      personal-access-token:
        description: GitHub Personal Access Token (PAT) with necessary scopes
        required: false

jobs:
  greeter:
    name: Greet the user
    runs-on: ubuntu-latest
    steps:
      uses: actions/checkout@main
      with:
        repository: ${{ inputs.repo }}
        token: ${{ secrets.personal-access-token }}
      run: |
        echo 'Hello, ${{ inputs.username }}!' \
          'The repo ${{ inputs.repo }} was checked out.' \
          'This is the ${{ inputs.environment }} environment.'
```

```yml
name: Downstream workflow that uses the reusable workflow

on:
  push:
  pull_request:
  workflow_dispatch:

jobs:
  greet_me:
    uses: org/repo/.github/workflows/greeter.yml@main
    with:
      username: Octocat
      repo: my-private-repo
      personal-access-token: ${{ secrets.MY_GITHUB_PAT }}
```

```text
Hello, Octocat! The repo my-private-repo was checked out. This is the development environment.
```

### Error handling

- Use [`continue-on-error: true` on a step](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) to continue the job if the step fails, and use [`if: steps.<step_id>.outcome == 'success'`](https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context) to trigger downstream steps only if the step succeeds.
- Use [`continue-on-error: true` on a job](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idcontinue-on-error) to continue to the next job if the current job fails, and use [`if: jobs.<job_id>.outcome == 'success'`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_id) to trigger downstream jobs only if the job succeeds.

### Environments

GitHub Actions offers [environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment), which allow branch protection rules and secrets to be set individually for each environment (instead of for the repo as a whole). The way they've set up environments is a little confusing, and most of the functionality of environments can be implemented with other features like `strategy.matrix` or environment variables.

Let's look at a common use case that highlights the limitations of environments: deploying a service to multiple cloud regions. We'll use two environments that map to Git branches, and two cloud regions for each environment.

#### Setting up environments

1. In a GitHub repo's settings, add an **[environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)** for each combo of Git branch and AWS region. For example, for two Git branches and two AWS regions, the environment names could be:
   - `development-us-east-1`
   - `development-us-west-2`
   - `production-us-east-1`
   - `production-us-west-2`
2. In each environment's **environment protection rules**, set the **deployment branch** to the corresponding Git branch:
   - `development-us-east-1`: `develop`
   - `development-us-west-2`: `develop`
   - `production-us-east-1`: `main`
   - `production-us-west-2`: `main`
3. In the **environment secrets** for each environment, set a secret with key `AWS_REGION` and value set to the corresponding AWS region. These aren't necessarily sensitive credentials, but GitHub uses secrets for all key-value pairs. Examples:
   - `development-us-east-1`: secret name: `AWS_REGION`, secret value: `us-east-1`
   - `development-us-west-2`: secret name: `AWS_REGION`, secret value: `us-west-2`
   - `production-us-east-1`: secret name: `AWS_REGION`, secret value: `us-east-1`
   - `production-us-west-2`: secret name: `AWS_REGION`, secret value: `us-west-2`
4. **[Reference the environment name within GitHub Actions workflows](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idenvironment)**, optionally limiting **[workflow concurrency](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency)** by each environment.

#### Minimal example

```yml
name: multi-region environment example

on:
  push:
    branches: [develop, main]
  workflow_dispatch:

jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      deploy-env: ${{ steps.set-deploy-env.outputs.deploy-env }}
    steps:
      - uses: actions/checkout@main
      - name: Set deployment environment based on Git branch
        id: set-deploy-env
        run: |
          if ${{ github.ref == 'refs/heads/main' }} || ${{ startsWith(github.ref, 'refs/tags/') }}; then
            DEPLOY_ENV="production"
          else
            DEPLOY_ENV="development"
          fi
          echo "deploy-env=$DEPLOY_ENV" >>"$GITHUB_OUTPUT"
  deploy:
    needs: [setup]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        aws-region: [us-east-1, us-west-2]
    environment:
      name: ${{ needs.setup.outputs.deploy-env }}-${{ matrix.aws-region }}
    concurrency: ${{ environment.name }}
    steps:
      - uses: aws-actions/configure-aws-credentials@master
        id: aws-login
        with:
          aws-region: ${{ secrets.AWS_REGION }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      - run: echo "This job will deploy to the environment named ${{ environment.name }}."
```

#### Limitations

By the time you've done all the setup to actually specify the deployment environment and region, you already have the region you need, and the environment isn't particularly useful. For example, in the `aws-login` step above, the `aws-region: ${{ secrets.AWS_REGION }}` value could be replaced by `aws-region: ${{ matrix.aws-region }}`. It would be more helpful to have an environment automatically apply to a Git branch or a workflow, and then be able to reference the configuration values within workflows automatically. It's actually the opposite. You have to specify the environment from within the workflow, and then if the environment protection rules are met, you get access to the corresponding environment secrets.

### VMs and pricing

- **VM info**: The GitHub Actions runner [provisions virtual machines](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) with similar resources as [AWS EC2 `t2.large` instances](https://aws.amazon.com/ec2/instance-types/).
  - 2-core CPU
  - 7 GB of RAM memory
  - 14 GB of SSD disk space
- To find out what's installed on the runner images, see the [actions/runner-images](https://github.com/actions/runner-images) repo.
- GitHub Actions is free for open-source repos. Pricing for other repos only kicks in if you exceed the allotted build minutes.

  <img src="https://gist.githubusercontent.com/br3ndonland/f9c753eb27381f97336aa21b8d932be6/raw/194dc0e4b8b02e29fe50477a48e0e07aa09408db/images-features-pricing.png" alt="GitHub Actions pricing info from https://github.com/features/actions" width="800px">

### GitHub Actions and Poetry

[Poetry](https://python-poetry.org/) is a useful tool for Python packaging and dependency management. The following set of tips was originally posted to [python-poetry/poetry#366](https://github.com/python-poetry/poetry/issues/366#issuecomment-691412462).

#### Use caching to speed up workflows

Use [actions/cache](https://github.com/marketplace/actions/cache) with a variation on their [`pip` cache example](https://github.com/actions/cache/blob/main/examples.md) to cache Poetry dependencies for faster installation.

```yml
- name: Set up Poetry cache for Python dependencies
  uses: actions/cache@main
  if: startsWith(runner.os, 'Linux')
  with:
    path: ~/.cache/pypoetry
    key: ${{ runner.os }}-poetry-${{ hashFiles('**/poetry.lock') }}
    restore-keys: ${{ runner.os }}-poetry-
```

#### Install Poetry with `pipx`

Installing Poetry via `pip` can lead to dependency conflicts, and their "custom installer" script (`get-poetry.py`/`install-poetry.py`) has been problematic. Instead, Poetry can be installed with [`pipx`](https://pypa.github.io/pipx/). Versions of `pipx` and Poetry can be pinned to promote reproducible installations.

```yml
- name: Install pipx
  run: python -m pip install "pipx==0.16.4"
- name: Install Poetry
  run: pipx install "poetry==1.1.11"
- name: Install dependencies
  run: poetry install --no-interaction
```

#### Build and publish in one step

- [Create a PyPI token](https://pypi.org/help/#apitoken).
- Add it to the [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) store for the repo _(Settings -> Secrets)_.
- Use the secret in your workflow with `${{ secrets.PYPI_TOKEN }}` (secret name is `PYPI_TOKEN` in this example, and username for PyPI tokens is `__token__`).
- Use [`poetry publish --build`](https://python-poetry.org/docs/cli/#publish) to build and publish in one step.

```yml
- name: Build Python package and publish to PyPI
  if: startsWith(github.ref, 'refs/tags/')
  run: poetry publish --build -u __token__ -p ${{ secrets.PYPI_TOKEN }}
```

That's why they call it Poetry. Beautiful.

#### Example workflow

<details><summary><em>Expand this details element for an example workflow that uses these tips.</em></summary>

```yml
name: ci

on:
  pull_request:
  push:
    branches: [develop, main]
    tags:
      - "[0-9]+.[0-9]+.[0-9]+*"
  workflow_dispatch:

jobs:
  ci:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10"]
    env:
      PIPX_VERSION: "0.16.4"
      POETRY_VERSION: "1.1.11"
      POETRY_VIRTUALENVS_IN_PROJECT: true
    steps:
      - uses: actions/checkout@main
      - uses: actions/setup-python@main
        with:
          python-version: ${{ matrix.python-version }}
      - name: Set up Poetry cache for Python dependencies
        uses: actions/cache@main
        if: startsWith(runner.os, 'Linux')
        with:
          path: ~/.cache/pypoetry
          key: ${{ runner.os }}-poetry-${{ hashFiles('**/poetry.lock') }}
          restore-keys: ${{ runner.os }}-poetry-
      - name: Install pipx for Python ${{ matrix.python-version }}
        run: python -m pip install "pipx==$PIPX_VERSION"
      - name: Install Poetry
        run: pipx install "poetry==$POETRY_VERSION"
      - name: Test Poetry version
        run: |
          POETRY_VERSION_INSTALLED=$(poetry -V)
          echo "The POETRY_VERSION environment variable is set to $POETRY_VERSION."
          echo "The installed Poetry version is $POETRY_VERSION_INSTALLED."
          case $POETRY_VERSION_INSTALLED in
          *$POETRY_VERSION*) echo "Poetry version correct." ;;
          *) echo "Poetry version incorrect." && exit 1 ;;
          esac
      - name: Install dependencies
        run: poetry install --no-interaction
      - name: Test virtualenv location
        run: |
          EXPECTED_VIRTUALENV_PATH=${{ github.workspace }}/.venv
          INSTALLED_VIRTUALENV_PATH=$(poetry env info --path)
          echo "The virtualenv should be at $EXPECTED_VIRTUALENV_PATH."
          echo "Poetry is using a virtualenv at $INSTALLED_VIRTUALENV_PATH."
          case "$INSTALLED_VIRTUALENV_PATH" in
          "$EXPECTED_VIRTUALENV_PATH") echo "Correct Poetry virtualenv." ;;
          *) echo "Incorrect Poetry virtualenv." && exit 1 ;;
          esac
      - name: Run unit tests
        run: poetry run pytest tests
      - name: Build Python package with latest stable Python version and publish to PyPI
        if: matrix.python-version == '3.10' && startsWith(github.ref, 'refs/tags/')
        run: |
          PACKAGE_VERSION=$(poetry version -s)
          GIT_TAG_VERSION=$(echo ${{ github.ref }} | cut -d / -f 3)
          echo "The Python package version is $PACKAGE_VERSION."
          echo "The Git tag version is $GIT_TAG_VERSION."
          if [ "$PACKAGE_VERSION" = "$GIT_TAG_VERSION" ]; then
            echo "Versions match."
          else
            echo "Versions do not match." && exit 1
          fi
          poetry publish --build -u __token__ -p ${{ secrets.PYPI_TOKEN }}
```

</details>

#### Bonus: automated dependency updates with Dependabot

Dependabot now offers [automated version updates](https://github.blog/2020-06-01-keep-all-your-packages-up-to-date-with-dependabot/), with (preliminary) support for Poetry :tada:. If you have access to the Dependabot beta, set up _.github/dependabot.yml_ as described in the [docs](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates):

```yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

Dependabot will now send you PRs when dependency updates are available. Although `package-ecosystem` must be set to `pip`, it will pick up the _pyproject.toml_ and _poetry.lock_. Check the status of the repo at _Insights -> Dependency graph -> Dependabot_.

## Challenges

### Lacking necessary `on:` triggers

**There's no PR merge trigger**. To run a workflow when PRs are merged, use `pull_request:` `types: [closed]` as the [event trigger](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows) and only run each job if the [GitHub event](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context) payload contains `merged == 'true'`.

```yml
name: demo
on:
  pull_request:
    types: [closed]
jobs:
  job1:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == 'true'
    steps:
      - name: step1
        run: echo 'pull request was merged'
```

**Triggers have confusing restrictions**. Some events will only trigger workflows if the YAML syntax is on the default branch, and some events can only run on the default branch. For example, here is a comparison of `repository_dispatch` and `workflow_dispatch`:

- [`repository_dispatch`](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#repository_dispatch)
  - _Where the YAML needs to be:_
    - Default branch. Docs say "Note: This event will only trigger a workflow run if the workflow file is on the default branch." This means that the YAML file must be committed to the repo's default branch, and the `repository_dispatch:` trigger must be in the YAML file.
  - _Which branches it can run on:_
    - Default branch only.
  - _How it's triggered:_
    - [Webhook event through the GitHub API](https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#repository_dispatch). For example, let's say you use GitHub Actions to build and deploy a Docker container to Azure. It deploys successfully, but later maybe the connection to the database starts failing because of an outdated password or something. You can set up Azure to send a webhook to GitHub, and re-deploy the container.
- [`workflow_dispatch`](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch)
  - _Where the YAML needs to be:_
    - Default branch (though the docs don't say this directly).
  - _Which branches it can run on:_
    - Any branch.
  - _How it's triggered:_
    - [Manually through the GitHub UI](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow)
    - [Manually through the GitHub CLI](https://cli.github.com/manual/gh_workflow_run)
    - [Webhook event through the GitHub API](https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#workflow_dispatch)

**Environment variables can't be set per-trigger**. It's difficult to set environment variables per-trigger, such as based on which branch was checked out. There's a top-level `env:` key, but it doesn't allow expressions or separate `steps:`.

```yaml
env: # Can't do this
  - name: Set build environment to production if master branch is checked out
    if: contains(github.ref, 'master')
    run: echo "BUILD_ENV=production" >>"$GITHUB_ENV"
  - name: Set build environment to development if develop branch is checked out
    if: contains(github.ref, 'develop')
    run: echo "BUILD_ENV=development" >>"$GITHUB_ENV"
  - name: Set build environment to test otherwise
    if: ${{ !contains(github.ref, 'master') || !contains(github.ref, 'develop') }}
    run: echo "BUILD_ENV=test" >>"$GITHUB_ENV"
```

Furthermore, environment variables set to `$GITHUB_ENV` within a job are scoped to that job.

The solution is to [use outputs instead of environment variables](https://github.community/t/16277). Set outputs from one job and read them in downstream jobs. Note that _step_ outputs must also be set as _job_ outputs in order to be passed to other workflows.

### PR merge conflicts blocking workflow runs

- If a PR has merge conflicts, GitHub Actions workflows may not run at all. See [this GitHub community thread](https://github.community/t/run-actions-on-pull-requests-with-merge-conflicts/17104/13).
- Try using [equality operators](https://docs.github.com/en/actions/learn-github-actions/expressions#operators) (`==` and `!=`) to check out the PR `HEAD` commit, instead of the default (the merge commit), as described in the [actions/checkout README](https://github.com/actions/checkout):

  ```yml
  - uses: actions/checkout@main
    if: ${{ github.event_name != 'pull_request' }}
  - uses: actions/checkout@main
    if: ${{ github.event_name == 'pull_request' }}
    with:
      ref: ${{ github.event.pull_request.head.sha }}
  ```

- If checking out the `HEAD` commit doesn't work, you may need to resolve merge conflicts to continue.

### Understanding context and expression syntax

- See the [context](https://docs.github.com/en/actions/learn-github-actions/contexts) and [expression](https://docs.github.com/en/actions/learn-github-actions/expressions) syntax docs
- In which context can I use which things?
  - _Where can I define `env:`?_
  - _Where can I define `defaults:`?_
  - _Where can I add `if:`?_
  - _Where do I need `${{ }}` for expressions?_ The [docs](https://docs.github.com/en/actions/learn-github-actions/contexts) explain that `if:` conditionals are automatically evaluated as expressions, but it's not always clear in other fields.
- There are syntactic subtleties, such as the requirement for single quotes in some YAML [contexts](https://docs.github.com/en/actions/learn-github-actions/contexts):

  ```yaml
  jobs:
    job1:
      runs-on: ubuntu-latest
      steps:
        # this works
        - name: Set build environment to production
          if: github.ref == 'refs/heads/master'
          run: echo "BUILD_ENV=production" >>"$GITHUB_ENV"
        # this doesn't because of "" in the if:
        - name: Set build environment to production
          if: github.ref == "refs/heads/master"
          run: echo "BUILD_ENV=production" >>"$GITHUB_ENV"
  ```

- Or the requirement for quoting in other contexts, such as for [Python 3.10](https://github.com/actions/setup-python/issues/249#issuecomment-934299359):

  ```yaml
  jobs:
    job1:
      runs-on: ubuntu-latest
      strategy:
        matrix:
          # 3.10 without quotes will be parsed as 3.1
          python-version: [3.8, 3.9, "3.10"]
      steps:
        - uses: actions/checkout@main
        - uses: actions/setup-python@main
          with:
            python-version: ${{ matrix.python-version }}
        - run: echo "Python version is ${{ matrix.python-version }}"
  ```

- There's no concept of `if/elif/else`.
- [Object filters](https://docs.github.com/en/actions/learn-github-actions/expressions#object-filters) seem useful, but there's no explanation for how to set up object filters within workflows.
- There are sometimes several context keys with similar values , like `github.base_ref` vs. `github.ref_name` vs. `github.ref`:
  - `github.base_ref` and `github.ref_name` return just the branch name, like `main`.
  - `github.ref` returns the full Git ref, like `refs/heads/main`.

## Resources

- **Overview**
  - [GitHub Actions Cheat Sheet](https://resources.github.com/whitepapers/GitHub-Actions-Cheat-sheet/)
  - [GitHub docs: Actions - Core concepts](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)
  - [GitHub docs: Actions - Using workflows](https://docs.github.com/en/actions/using-workflows)
- **Workflow triggers** (the `on:` section of YAML workflow files):
  - [GitHub docs: Actions - Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
  - [GitHub Blog 20200706: GitHub Actions - Manual triggers with `workflow_dispatch`](https://github.blog/changelog/2020-07-06-github-actions-manual-triggers-with-workflow_dispatch/)
- **Workflow syntax**
  - [GitHub docs: Actions - Commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions) (special commands you can send to the runner within workflows, like `echo "COLOR=green" >>"$GITHUB_ENV"`)
  - [GitHub docs: Actions - Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts) (metadata like `${{ github.repository }}`)
  - [GitHub docs: Actions - Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions) (syntax in double curly braces like `${{ format() }}`)
  - [GitHub docs: Actions - Workflow syntax reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- **GitHub Actions + GitHub Container Registry**
  - [GitHub Blog 20200901: Introducing GitHub Container Registry](https://github.blog/2020-09-01-introducing-github-container-registry/)
  - [GitHub docs: Learn GitHub Packages](https://docs.github.com/en/packages/learn-github-packages)
- **Actions**
  - [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
  - [actions/runner](https://github.com/actions/runner): the runner for GitHub Actions
  - [sdras/awesome-actions](https://github.com/sdras/awesome-actions)

## GitHub Gist notes <!-- omit in toc -->

- A **Gist** is actually a repository.
- To clone the Gist locally:
  ```sh
  git clone git@gist.github.com:f9c753eb27381f97336aa21b8d932be6.git github-actions
  ```
- **No subdirectories are allowed.**
- To add images to a Markdown file in a Gist:
  - Commit the image file (in the same directory, no sub-directories)
  - Push the change to GitHub with `git push`
  - Click on the "raw" button next to the image
  - Copy the URL
  - Add the URL to an image tag in the Markdown file.
