<template>
  <v-app id="coindreeder" class="mt-0">
    <div v-if="notInstalled === true">
      <NotInstalled />
    </div>
    <div v-else-if="notInstalled === false">
      <div id="nav" v-if="hasInjected === false">
        <MetamaskLogin />
      </div>
    </div>
    <div v-if="hasInjected==true">
      <loading
        :active.sync="$store.state.loading"
        background-color="#9b9999"
        color="#2c80ff"
        loader="dots"
        transition="fade"
        :height="150"
        :width="150"
        is-full-page
      ></loading>
        <v-snackbar v-model="$store.state.snackbar" top :color="$store.state.color" :timeout="$store.state.timeout">
      {{ $store.state.text }}
      <template v-slot:action="{ attrs }">
        <v-btn class="mx-0 px-0" color="white" text v-bind="attrs" @click="$store.state.snackbar = false"><v-icon>mdi-close-circle-outline</v-icon></v-btn>
      </template>
    </v-snackbar>

      <v-navigation-drawer
        v-model="primaryDrawer.model"
        :clipped="true"
        :floating="true"
        :temporary="true"
        overflow
        app
      >
        <v-list-item style="height: 25px" class="ma-2">
          <v-list-item-content>
            <v-list-item-title class="title" align="center" justify='center'>
              <v-img src="./assets/light.png" max-width="60" class="d-block d-md-none" v-if="!$vuetify.theme.dark" contain />
              <v-img src="./assets/dark.png" max-width="60" class="d-block d-md-none" v-if="$vuetify.theme.dark" contain />
            </v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-divider></v-divider>
        <v-list nav>
          <v-list-item v-for="item in items" :key="item.title" :to="item.to" link style="color: #317FD5 !important;" text small>
            <v-list-item-icon>
              <component :is="item.component"></component>
            </v-list-item-icon>
            <v-list-item-content>
              <v-list-item-title>{{ item.title }}</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-navigation-drawer>
      <v-app-bar
        app
        elevation="0"
        style="border-bottom: 1px solid #e6ecf0"
        :class="{ 'bar-light': !$vuetify.theme.dark, 'bar-dark':  $vuetify.theme.dark }"
      >
        <v-app-bar-nav-icon
          @click.stop="primaryDrawer.model = !primaryDrawer.model"
          class="d-sm-block d-md-none"
        ></v-app-bar-nav-icon>
        <v-toolbar-title class="pr-md-12">
          <v-img src="./assets/light.png" max-width="70" class="d-none d-md-block" v-if="!$vuetify.theme.dark" contain />
          <v-img src="./assets/dark.png" max-width="70" class="d-none d-md-block" v-if="$vuetify.theme.dark" contain />
          <v-img src="./assets/light.png" max-width="50" class="d-block d-md-none" v-if="!$vuetify.theme.dark" contain />
          <v-img src="./assets/dark.png" max-width="50" class="d-block d-md-none" v-if="$vuetify.theme.dark" contain />
        </v-toolbar-title>
        <v-btn
          to="/staking"
          class="d-none d-md-flex text-caption text-capitalize"
          color="primary"
          text
        >
          <ZapIcon size="1.5x" class="custom-class mr-1"></ZapIcon>Staking
        </v-btn>
        <v-btn
          to="/farming"
          class="d-none d-md-flex text-caption text-capitalize ml-1"
          color="primary"
          text
        >
          <SettingsIcon size="1.5x" class="custom-class mr-1"></SettingsIcon>Farming
        </v-btn>
        <v-spacer></v-spacer>
        <!-- <v-btn class="ma-2" small color="primary">Connect Wallet</v-btn> -->
        <v-btn
          v-if="currentAddress==undefined"
          class="ma-2 d-none d-md-block"
          small
          outlined
          color="indigo"
        >Address</v-btn>
        <v-btn
          v-else
          class="ma-2 d-none d-md-block"
          small
          outlined
          :color="color"
        >{{currentAddress}}</v-btn>
        <v-menu :close-on-content-click="false" :nudge-width="200" offset-x>
          <template v-slot:activator="{ on, attrs }">
            <v-btn v-bind="attrs" v-on="on" icon>
              <v-icon>mdi-dots-vertical</v-icon>
            </v-btn>
          </template>
          <v-card>
            <v-list class="pr-5">
              <v-list-item>
                <v-list-item-avatar>
                  <MoonIcon style="height: 25px"></MoonIcon>
                </v-list-item-avatar>
                <v-list-item-title>Dark Mode</v-list-item-title>
                <v-list-item-action>
                  <v-switch color="primary" v-model="$vuetify.theme.dark"></v-switch>
                </v-list-item-action>
              </v-list-item>
            </v-list>
          </v-card>
        </v-menu>
      </v-app-bar>
      <v-main>
        <v-container fluid>
          <keep-alive>
          <router-view></router-view>
          </keep-alive>
        </v-container>
      </v-main>
      <!-- <v-footer app>
        <span class="px-4">{{ new Date().getFullYear() }} &copy; Coinbreeder.com.</span>
      </v-footer> -->
    </div>
  </v-app>
</template>

<script>
import Web3 from "web3";
import { ZapIcon, SettingsIcon, MoonIcon } from "vue-feather-icons";
export default {
  name: "App",
  components: {
    ZapIcon,
    SettingsIcon,
    MoonIcon,
    NotInstalled: () => import("./components/Login/NotInstalled"),
    MetamaskLogin: () => import("./components/Login/MetamaskLogin"),
  },
  data: () => ({
    currentAddress: undefined,
    hasInjected: null,
    chainId: null,
    networkId: null,
    notInstalled: null,
    networkArr: [
      {
        id: 5,
        name: "goerli",
      },
      {
        id: 3,
        name: "ropsten",
      },
      {
        id: 42,
        name: "kovan",
      },
      {
        id: 4,
        name: "rinkeby",
      },
      {
        id: 1,
        name: "main",
      },
    ],
    items: [
      { title: "Staking", icon: "mdi-view-dashboard", to: "/staking", component: 'ZapIcon' },
      { title: "Farming", icon: "mdi-image", to: "/farming", component: 'SettingsIcon' },
    ],
    primaryDrawer: {
      model: null,
    },
    footer: {
      inset: false,
    },
  }),
  computed: {
    color(){
      return this.$vuetify.theme.dark ? 'indigo lighten-3' : 'indigo'
    }
  },
  async created() {
    await this.ethEnabled();
     await this.getNetwork();
    await this.getCurrentAccount();
    this.networkType = await window.web3.eth.net.getNetworkType();
   
    window.ethereum.on("networkChanged", async (chainId) => {
      this.networkArr.forEach((a) => {
        console.log(a);
        if (a.id == chainId) {
          if (a.name != this.networkType) {
            window.location.reload();
          }
        }
      });
      console.log("id", chainId);
    });
    
    
  },
  async mounted() {
    this.$store.state.loading=true;
    await this.$store.dispatch("setCurrentAddress");
    await this.$store.dispatch("setBreedContract");
    await this.$store.dispatch("setDaoContract");
  

    // this.$store.state.loading=false;
    this.currentAddress = this.$store.state.currentAddress;
  },
  methods: {
    ethEnabled() {
      if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        // window.ethereum.enable();
        this.notInstalled = false;
      } else {
        this.notInstalled = true;
      }
    },
    async getCurrentAccount() {
      let account = await window.web3.eth.getAccounts();
      console.log("accc", account);
      this.currentAccount = account[0];
      var accountInterval = setInterval(async () => {
        let acc = await window.web3.eth.getAccounts();
        if (acc[0] !== account[0]) {
          window.location.reload();
        }
      }, 300);
    },
    async getNetwork() {
      console.log(window.web3.eth);
      let network = await window.web3.eth.net.getNetworkType();
      console.log(network);
      let address = await window.web3.eth.getAccounts();
      if (
        network != "private" &&
        address != "" &&
        address != "undefined" &&
        address.length > 0
      ) {
        if (network == "goerli") {
          this.hasInjected = true;
        } else {
          this.hasInjected = false;
        }
      } else {
        this.hasInjected = false;
      }
    },
  },
};
</script>

<style>
.card-title-bg-light {
  background-color: #f8f9fa;
}
.card-title-bg-dark {
  background-color: #323942;
}
.bar-dark {
  background-color: #a9b1bb;
  border-bottom: 1px solid #3c424c;
}
.bar-light {
  background-color: #ffffff;
  border-bottom: 1px solid #e6ecf0;
}
.hr-styles {
  height: 1px;
  background-color: #ccc;
  border: none;
  opacity: 0.5;
}
.btn-bg {
  font-size: 12px !important;
  background-color: white !important;
  border-color: #1976D2 !important;
  color: #1976D2 !important 
}
.btn-bg:hover {
  background-color: #1976D2 !important;
  color: #ffffff !important;
}

.stake-cards{
  color:rgba(0,0,0,.6);
  font-size: 18px;
  height:54px;
  margin:8px;
  padding: 12px 28px;
}
.stake-cards-light{
  color:rgba(255, 255, 255, 0.7);
   font-size: 18px;
  height:54px;
  margin:8px;
  padding: 12px 28px;
}

</style>