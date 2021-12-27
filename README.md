# kafka-kind - a local kafka development environment

`kafka-kind` creates a friendly development environment on your local machine using [docker], [kind],
[kubernetes] and a [cast of thousands](https://idioms.thefreedictionary.com/cast+of+thousands).

this document considers these platforms as distinct:

* [Linux](https://en.wikipedia.org/wiki/Linux)
* [macOS](https://en.wikipedia.org/wiki/MacOS)
* [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows)
* [Windows Subsystem for Linux 2 (WSL2)](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)

this document should be followed from top to bottom, executing all the relevant parts.  (Linux users need not execute the commands exclusive for macOS, _etc_.)

## Setup

### Microsoft Windows

this is a complex, convoluted mess to keep running, and worse to do so consistently; switch to Linux for an easy experience.
that said, this is designed to run with bash which is provided by git so give it a try in the **All** sections.

* install [Chocolatey](https://chocolatey.org/install)
* install packages in an [Administrator shell](https://superuser.com/questions/968214/open-cmd-as-admin-with-windowsr-shortcut)
* download [Confluent Platform](https://packages.confluent.io/archive/6.1/confluent-6.1.1.zip) and extract to `C:\tools`.

  ```bat
  choco install \
    apache-zookeeper \
    git \
    jq \
    kind \
    kubernetes-helm \
    python3 \
    wireguard \
    zulu8
  pip install yq
  setx PATH "%PATH%;C:\tools\confluent-6.1.1\bin;C:\tools\zookeeper-3.4.9\bin" /M
  setx JAVA_HOME C:\Progra~1\Zulu\zulu-8 /M
  ```

* append `hosts` to `C:\Windows\System32\drivers\etc\hosts`
* install [Windows Subsystem for Linux 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-2---update-to-wsl-2)
* install [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
* install a Linux distribution
* install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/release-notes/3.x/).  note that i recommend older version 3 due to [recent docker license](https://www.theregister.com/2021/08/31/docker_desktop_no_longer_free/) [fubar](https://en.wikipedia.org/wiki/List_of_military_slang_terms#FUBAR).

because of the multiple but distinct personalities that is MS Windows with WSL2 much of the configuration below must be replicated in MS Windows.  lucky you.  more on this later.

### macOS

* install [Homebrew]
* install [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/release-notes/3.x/).  note that i recommend older version 3 due to [recent docker license](https://www.theregister.com/2021/08/31/docker_desktop_no_longer_free/) [fubar](https://en.wikipedia.org/wiki/List_of_military_slang_terms#FUBAR).

* Docker Desktop by default configures the internal Linux VM for 2GB Memory which is insufficient to load all the samples.
  Open _Preferences_ / _Resources_ and increase Memory to at least 4GB.

### Linux

* install [Homebrew](https://docs.brew.sh/Homebrew-on-Linux)

### All [Un*x]

* Configure packages

  ```bash
  brew install \
    jkt628/revived/confluent-platform \
    curl \
    docker-compose \
    helm \
    jq \
    kind \
    kubectl \
    wireguard-tools \
    zookeeper
  sudo tee -a /etc/hosts <hosts >/dev/null
  ```

### All

  ```bash
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts
  helm repo add metallb https://metallb.github.io/metallb
  helm repo add stable https://charts.helm.sh/stable
  ```

### More [Un*x]

#### Warnings

* _confluent-platform_ and _zookeeper_ both fail with _openjdk_ which is currently Java 17.
  If `java -version` > 11 install another JDK and _jenv_:

  ```bash
  brew install homebrew/cask-versions/zulu8
  brew install jenv # and activate, follow Caveats
  source ~/.bash_profile
  find /usr/local/Cellar /Library/Java /home/linuxbrew -mount -type f -name java 2>/dev/null | sed -n '\,/bin/java$,{s,,,;p;}' | xargs -n1 jenv add
  jenv local 1.8
  ```

### Microsoft Windows: additional setup

* launch [Git BASH as Administrator](https://dirask.com/posts/How-to-open-Git-Bash-as-administrator-on-Windows-VDK7gD)

  ```bash
  git -c core.symlinks=true clone https://github.com/jkt628/kafka-kind
  cd kafka-kind
  curl -L http://packages.confluent.io/archive/6.1/confluent-community-6.1.1.tar.gz | tar xzvf - -C '/c/tools'
  ```

* configure WireGuard
  * launch `File Explorer`
  * navigate to `...\kafka-kind\wireguard`
  * double-click `dangerous.reg`

* route to cluster
  * launch WireGuard
  * Import tunnel(s) from file...
  * navigate to `...\kafka-kind\wireguard`
  * `wg1.conf`
  * Activate

  note it will not handshake until kafka-kind is launched later.

## Launch cluster with zookeeper, kafka, schema registry, _etc._

```bash
./kafka-kind
```

### Microsoft Windows: more fun and games

because the cluster runs in docker it is accessible to both Microsoft Windows and Linux via WSL2; however, the control plane port and authentication keys change with every launch.  synchronize the current settings to the other platform:

```bash
kind export kubeconfig --name kafka
```

## Samples: schemas and topics

* Load everything

  ```bash
  ./kafka-kind all
  ```

* Load partial

  ```bash
  ./kafka-kind schemas/canary-value.avsc topics/canary.json
  ```

## Use components

### zookeeper

```bash
zkCli -server zookeeper.kafka:2181
```

### kafka

```bash
kafka-topics --bootstrap-server=kafka.kafka:9092 --list
curl -sSf kafka-rest.kafka/topics | jq -r 'sort[]'
```

### schema registry

```bash
curl -sSf http://schema.kafka/subjects | jq -r 'sort[]'
```

### CMAK (the tool previously known as "Kafka Manager")

```bash
[ $(uname) == Darwin ] && alias xdg-open=open
xdg-open http://cmak.kafka
```

## Clean

```bash
./kafka-kind down
```

## Resources

* [docker]
* [Local Registry](https://kind.sigs.k8s.io/docs/user/local-registry/)
* [Homebrew]
* [Kind SIG](https://kind.sigs.k8s.io/)
* [Kind-ly running Contour](https://projectcontour.io/kindly-running-contour/)
* [Using MetalLb with Kind](https://mauilion.dev/posts/kind-metallb/)
* [WireGuard](https://en.wikipedia.org/wiki/WireGuard)

[docker]: https://en.wikipedia.org/wiki/Docker_(software)
[Homebrew]: https://brew.sh
[kind]: https://kind.sigs.k8s.io/
[kubernetes]: https://en.wikipedia.org/wiki/Kubernetes
[Un*x]: https://en.wikipedia.org/wiki/Unix-like
