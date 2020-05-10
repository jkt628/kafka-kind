# kafka-kind - a local kafka development environment

## Resources

* [Homebrew](https://brew.sh)
* [Kind SIG](https://kind.sigs.k8s.io/)
* [Kind-ly running Contour](https://projectcontour.io/kindly-running-contour/)
* [Using the NetworkManager’s DNSMasq plugin](https://fedoramagazine.org/using-the-networkmanagers-dnsmasq-plugin/)
* [Using Dnsmasq for local development on OS X](https://passingcuriosity.com/2013/dnsmasq-dev-osx/)
* [Using MetalLb with Kind](https://mauilion.dev/posts/kind-metallb/)
* [KIND and Load Balancing with MetalLB on Mac](https://www.thehumblelab.com/kind-and-metallb-on-mac/)

## Setup

### Microsoft Windows

you have my pity but [i don't do windows](https://i.chzbgr.com/full/6934765056/hE935F30E/i-dont-do-windows).

### macOS

* install [Homebrew](https://brew.sh)
* install [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/), or

  ```bash
  brew cask install docker-edge
  ```

* Docker Desktop by default configures the internal Linux VM for 2GB Memory which is insufficient to load all the samples.
  Open _Preferences_ / _Resources_ and increase Memory to at least 4GB.

* install docker-tun-tap - this needs repeating after every docker upgrade

  ```bash
  docker-tuntap-osx/sbin/docker_tap_install.sh
  ```

* install dnsmasq

  ```bash
  brew install dnsmasq
  dnsmasq=/usr/local/etc/dnsmasq
  [ -f $dnsmasq.conf ] || cp $(brew list dnsmasq | grep /dnsmasq.conf) $dnsmasq.conf
  sed -i -e '/\*.conf/s/#//' $dnsmasq.conf
  mkdir -p $dnsmasq.d
  ln -sf $PWD/dnsmasq-{macOS,kafka}.conf $dnsmasq.d
  brew services restart dnsmasq
  sudo mkdir -p /etc/resolver
  sudo ln -sf $PWD/resolver-kafka /etc/resolver/kafka
  ```

### Linux

* install [Homebrew](https://docs.brew.sh/Homebrew-on-Linux)
* configure NetworkManager

  ```bash
  sudo cp NetworkManager-dnsmasq.conf /etc/NetworkManager/conf.d
  sudo cp dnsmasq-kafka.conf /etc/NetworkManager/dnsmasq.d
  sudo systemctl restart NetworkManager
  ```

### All

* Configure packages

  ```bash
  brew install \
    confluent-platform \
    curl \
    docker \
    helm \
    jq \
    kind \
    zookeeper
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts
  helm repo add stable https://kubernetes-charts.storage.googleapis.com
  ```

#### Warnings

* _confluent-platform_ and _zookeeper_ both fail with _openjdk_ which is currently Java 13.
  If `java -version` > 11 install another JDK and _jenv_:

  ```bash
  if [ $(uname) == Darwin ]; then
    brew tap adoptopenjdk/openjdk
    brew cask install adoptopenjdk/openjdk/adoptopenjdk8
  fi
  brew install jenv # and activate, follow Caveats
  source ~/.bash_profile
  find /usr/local/Cellar /Library/Java /home/linuxbrew -mount -type f -name java 2>/dev/null | sed -n '\,/bin/java$,{s,,,;p;}' | xargs -n1 jenv add
  jenv local 1.8
  ```

## Launch cluster with zookeeper, kafka, schema registry, _etc._

```bash
./kafka-kind
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
curl -sS kafka-rest.kafka/topics | jq -r 'sort | .[]'
```

### schema registry

```bash
curl -sS http://schema.kafka/subjects | jq -r 'sort | .[]'
```

### CMAK (the tool previously known as "Kafka Manager")

```bash
[ $(uname) == Darwin ] && alias xdg-open=open
xdg-open http://cmak.kafka
```

## Delete cluster

```bash
kind delete cluster --name kafka
```
