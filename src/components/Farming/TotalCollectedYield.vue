<template>
  <v-card class="mx-auto mt-2" height="175px" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <TrendingUpIcon size="0.8x" class="custom-class mr-1"></TrendingUpIcon><span class="font-weight-light" style="font-size: 17px;"> TOTAL COLLECTED YIELDS </span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light" style="font-size: 18px">
      <p class="ml-3 mt-2">{{this.$store.state.totalFarmClaimedGlobal}} YBREE</p>
    </v-card-text>
  </v-card>
</template>

<script>
import { TrendingUpIcon } from "vue-feather-icons";
  export default {
    components: {
      TrendingUpIcon
    },
    data: () => ({
      balance:0,
      currentAddress:""
    }),
    async created() {
      this.currentAddress=this.$store.state.currentAddress;
    }
  }
</script>