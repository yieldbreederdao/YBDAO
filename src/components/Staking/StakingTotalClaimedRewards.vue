<template>
  <v-card class="mx-auto mt-2" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <GiftIcon size="0.8x" class="custom-class mr-1"></GiftIcon><span class="font-weight-light" style="font-size: 17px;">TOTAL CLAIMED REWARDS</span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light my-2" style="font-size: 18px">
  {{$store.state.totalClaimedGlobal}} YBREE
    </v-card-text>
  </v-card>
</template>

<script>
import { GiftIcon } from 'vue-feather-icons'
  export default {
    components: {
      GiftIcon
    },
    data: () => ({
      currentAddress:undefined,
      balance:0
      //
    }),
   async created() {
       this.currentAddress=this.$store.state.currentAddress;
    },
  }
</script>