<template>
  <v-card class="mx-auto" height="270" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <CheckIcon size="0.8x" class="custom-class mr-1"></CheckIcon><span class="font-weight-light" style="font-size: 17px;">CLAIMED</span>
    </v-card-title>
    <v-divider></v-divider>
    <v-card-text class="font-weight-light my-2 px-7" style="font-size: 18px; height: 120px">
      {{ this.$store.state.totalFarmClaimedMe}} YBREE
    </v-card-text>
    <v-divider></v-divider>
  </v-card>
</template>

<script>
import { CheckIcon } from "vue-feather-icons";
  export default {
    components: {
      CheckIcon
    },
    data: () => ({
      //
     
    }),
    async created() {
       this.currentAddress=this.$store.state.currentAddress;
    },
  }
</script>