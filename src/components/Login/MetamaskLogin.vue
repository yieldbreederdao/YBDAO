<template>
  <div class="d-flex justify-center align-center flex-column lol"  style="min-height: 100vh">
    <h1 class="font-weight-light" style="color: #F3853A">Login to metamask</h1>
    <img src="../../assets/metamask.png" style="max-width:  200px" class="hidden-md-and-up mt-10">
    <img src="../../assets/metamask.png" style="max-width:  300px" class="hidden-sm-and-down mt-10">
    <v-btn class="mt-10 px-10" style="background-color: #F3853A; color: white;" @click="ethEnabled">Login</v-btn>
    <p class="mt-3" style="color: red; text-decoration: underline">Must select Goerli Network</p>
    <p v-if="network">Current network is: {{network}}</p>
  </div>
  </div>
</template>

<style>
  .lol {
    background-color: #E9EBEE;
  }
</style>

<script>
import Web3 from 'web3'
export default {
  data() {
    return {
      network: null
    }
  },
  async created() {
    await this.getNetwork()
  },
  methods: {
    ethEnabled() {
      if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        window.ethereum.request({method:'eth_requestAccounts'})
       // window.ethereum.enable();
        // this.notInstalled = false;
      }
    },
    async getNetwork() {
      this.network = await window.web3.eth.net.getNetworkType();
    }
  }
}
</script>