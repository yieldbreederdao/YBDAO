<template>
  <div class="farming-dashboard">
    <div>
      <div class="my-5 mx-3">
        <p class="ma-0 grey--text" style="font-size: 12px">Farming Dashboard</p>
        <h2 class="ma-0 font-weight-light">MY STATISTICS</h2>
      </div>
    </div>
    <hr class="mx-n5 hr-styles" />
    <div class="pa-3">
      <v-row>
        <v-col cols="12" md="3">
          <Balance />
        </v-col>
        <v-col cols="12" md="3">
          <FarmingBalance />
        </v-col>
        <v-col cols="12" md="3">
          <Farmed />
        </v-col>
        <v-col cols="12" md="3">
          <Claimed />
        </v-col>
      </v-row>
    </div>
    <div>
      <div class="mx-3">
        <h2 class="ma-0 mt-2 font-weight-light">GLOBAL STATISTICS</h2>
      </div>
      <div class="px-3">
        <v-row>
          <v-col cols="12" md="5">
            <LatestFarmingRates />
          </v-col>
          <v-col cols="12" md="5">
            <TotalCollectedYield />
          </v-col>
          <!-- <v-col cols="12" md="4">
            <TotalCollectableRewards />
          </v-col> -->
        </v-row>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Farming',
  components: {
    Balance: () => import('../components/Farming/Balance'),
    FarmingBalance: () => import('../components/Farming/FarmingBalance'),
    Farmed: () => import('../components/Farming/Farmed'),
    Claimed: () => import('../components/Farming/Claimed'),
    LatestFarmingRates: () => import('../components/Farming/LatestFarmingRates'),
    TotalCollectedYield: () => import('../components/Farming/TotalCollectedYield'),
    TotalCollectableRewards: () => import('../components/Farming/TotalCollectableRewards')
  },
  async created() {
    this.$store.state.loading=true;
     await this.$store.dispatch("setFarmDetails");
     this.$store.state.loading=false;
  },

}
</script>
