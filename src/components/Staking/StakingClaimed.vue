<template>
  <v-card class="mx-auto" height="220px" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <CheckIcon size="0.8x" class="custom-class mr-1"></CheckIcon> <span class="font-weight-light" style="font-size: 17px;">CLAIMED</span>
    </v-card-title>
    <hr class="hr-styles" />
    <div :class="{'stake-cards':!$vuetify.theme.dark,'stake-cards-light':$vuetify.theme.dark}" justify="center"  class="font-weight-light stake-cards">
      {{$store.state.totalClaimedMe}} YBREE
     
    </div>
    <hr class="hr-styles" />
  </v-card>
</template>

<script>
import { CheckIcon } from 'vue-feather-icons'
  export default {
    components: {
      CheckIcon
    },
    data: () => ({
      //
      currentAddress:undefined,
      balance:0
    }),
    async created() {
      this.currentAddress=this.$store.state.currentAddress
        
    },
  }
</script>