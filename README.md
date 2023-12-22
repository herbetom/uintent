# uintent

uintent is a framework utilizing the OpenWrt Iamge Builder to generate OpenWrt images with config.
The config is automatically applied on first boot.

The intention is to further abstract config from specific devices and providing a way to have
a single config for all Access Points in your network.

Take a look into the [`targets`](targets/) dir to see currently supported architecures and models.

## Dependecies

`subversion build-essential python3 gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time qemu-utils curl file rsync`

## Usage

1. install depencies
2. clone this repo
3. create the [config](#config)
4. download the Image Builder: `make UINTENT_TARGET=mediatek-filogic download`
5. build the firmware: `make UINTENT_TARGET=mediatek-filogic`
6. you will find the images in `output/`
7. if you've got Devices with diffrent architectures repeat the steps starting at 4.


## Config

An example config can be found under [docs/example-config/](docs/example-config).

Structure:

```
config/
├── default.mk
└── profile
    ├── AAAAAAAAAAAA.json
    ├── BBBBBBBBBBBB.json
    └── global.json
```

- `config/default.mk`: offers (so far) the abbility to include additional packages
- `config/profile/XXXXXXXXXXXX.json`: XXXXXXXXXXXX is the primary mac of a device. Allows overriding config on a per device base level. Merged with the global config.
- `config/profile/global.json`: global config that will be applied to all devices.
