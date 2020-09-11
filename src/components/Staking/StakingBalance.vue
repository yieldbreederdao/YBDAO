<template>
  <v-card class="mx-auto" height="220px" outlined>
    <v-card-title
      class="pa-3"
      :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }"
    >
      <activity-icon size="0.8x" class="custom-class mr-1"></activity-icon>
      <span class="font-weight-light" style="font-size: 17px;">BALANCE</span>
    </v-card-title>
    <hr class="hr-styles" />
    <div :class="{'stake-cards':!$vuetify.theme.dark,'stake-cards-light':$vuetify.theme.dark}" justify="center"  class="font-weight-light stake-cards">{{$store.state.breedBalance}} YBREE</div>
    <hr class="hr-styles" />
    <div class="pa-4 d-flex mb-0 pb-0">
      <v-dialog v-model="dialog" width="500">
        <template v-slot:activator="{ on, attrs }">
          <v-btn
            style="font-size: 12px; width: 145px"
            color="primary"
            v-bind="attrs"
            v-on="on"
            class="px-10 ml-2 mt-2"
            elevation="0"
            dark
          >
            <zap-icon size="1.2x" class="ml-n5"></zap-icon>
            <span class="ml-5">stake</span>
          </v-btn>
        </template>
        <v-card>
          <v-icon
            color="primary"
            class="ma-2"
            @click="dialog=false"
            style="float:right"
          >mdi-close-circle</v-icon>
          <v-card-text>
            <v-container>
              <div class="d-flex mt-10">
                <v-text-field
                  clearable
                  v-model.number="amount"
                  label="Amount*"
                  height="40px"
                  type="number"
                  dense
                  required
                  outlined
                ></v-text-field>
                <v-btn height="40px" class="ml-1 btn-bg" @click="amount = balance" outlined>All</v-btn>
              </div>
            </v-container>
          </v-card-text>
          <v-divider></v-divider>
          <v-card-actions>
            <v-spacer></v-spacer>
            <div class="d-flex flex-wrap">
              <v-btn
                class="mx-2 btn-bg"
                @click="approve"
                outlined
              >Approve
              </v-btn>
              <v-tooltip max-width="200px" transition="scroll-y-transition" bottom>
                <template v-slot:activator="{ on, attrs }">
                  <p class="mr-2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
                </template>
                <small>If this is your first time interacting with the staking contract, you are required to approve the contract. You won't have to approve ever again, once you have done this.</small>
              </v-tooltip>
              <v-btn
                class="mx-2 btn-bg"
                @click="stake"
                outlined
              >Stake
              </v-btn>
              <v-tooltip  max-width="200px" transition="scroll-y-transition" bottom>
                <template v-slot:activator="{ on, attrs }">
                  <p class="mr-2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
                </template>
                <small>Use this only if you do not have an actively staked balance. If this is your first time staking, you will need to 'approve' your balances first.</small>
              </v-tooltip>
              <v-btn
                class="mx-2"
                color="primary"
                @click="addToStake"
                style="font-size: 12px"
              >Add More
              </v-btn>
              <v-tooltip  transition="scroll-y-transition" bottom max-width="200px">
                <template v-slot:activator="{ on, attrs }">
                  <p class="mr-2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
                </template>
                <small>Use this only if you have an actively staked balance and you wish to add more. WARNING: Your lock-in period resets to Day 1.</small>
              </v-tooltip>
            </div>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
  
  </v-card>
</template>

<script>
import utils from "../../utils/abi";
import { ActivityIcon, ZapIcon, InfoIcon } from "vue-feather-icons";
export default {
  components: {
    ActivityIcon,
    ZapIcon,
    InfoIcon,
  },
  data: () => ({
    dialog: false,
    user:undefined,
    amount: 0,
    balance: 0,
    currentAddress: undefined,
  }),
  methods: {
    async approve() {
      let bal = await this.$store.state.BREED.methods
        .balanceOf(this.currentAddress)
        .call();
      this.balance = await window.web3.utils.fromWei(bal.toString(), "ether");
      if (this.amount == 0) {
         this.$store.state.color=""
        this.$store.state.text = "Amount should be more than 0";
       this.$store.state.snackbar = true;
      } else if (this.balance < this.amount) {
       this.$store.state.color="red"
        this.$store.state.text =
          "You don't have enough YBREE tokens to stake the specified amount.";
          this.$store.state.snackbar = true;
        return;
      } else if (this.balance >= this.amount) {
        try {
          this.$store.state.loading = true;
          let amount = await window.web3.utils.toWei(
            this.amount.toString(),
            "ether"
          );

          let done = await this.$store.state.BREED.methods
            .approve(utils.daoAddress, amount)
            .send({ from: this.currentAddress });
         this.$store.state.color = "green";
          this.$store.state.text = "Transaction completed successfully";
          this.$store.state.snackbar = true;
        } catch (err) {
          console.log(err);
          this.$store.state.color = "red";
           this.$store.state.text = "Transaction failed, something went wrong";
          this.$store.state.snackbar = true;
        } finally {
          this.$store.state.loading = false;
        
        }
      }
    },

    async stake() {
      let allowance = await await this.$store.state.BREED.methods
        .allowance(this.currentAddress, utils.daoAddress)
        .call();
      allowance = await window.web3.utils.fromWei(
        allowance.toString(),
        "ether"
      );
      if(this.user.activeDeposit>0){

           
           this.$store.state.text = "You already have active stake,instead use 'add more'  to increase your active stake";
           this.$store.state.color="red"
        this.$store.state.snackbar = true;
      }
      else if (this.amount == 0) {
        this.$store.state.color=""
        this.$store.state.text = "Amount should be more than 0";
        this.$store.state.snackbar = true;
      } else if (allowance < this.amount) {
        this.$store.state.color=""
        this.$store.state.text =
          "Please approve the specified amount to stake the tokens. Use 'Approve' button to do it";
        this.$store.state.snackbar = true;
      }
      else if(this.$store.state.breedBalance<this.amount){
        this.$store.state.color="red"
        this.$store.state.text="you don't have enough yBREE tokens";
         this.$store.state.snackbar=true;

        }
         else if (allowance >= this.amount) {
        try {
          this.$store.state.loading = true;
          let amount = await window.web3.utils.toWei(
            this.amount.toString(),
            "ether"
          );
          let done = await this.$store.state.DAO.methods
            .STAKE(amount)
            .send({ from: this.currentAddress });
         await this.$store.dispatch('setStakeDetails');
          this.$store.state.timer=! this.$store.state.timer
          this.dialog=false;
         this.$store.state.color = "green";
          this.$store.state.text = "Transaction completed successfully";
          this.$store.state.snackbar = true;
        } catch (err) {
          console.log(err);
          this.$store.state.color = "red";
          this.$store.state.text = "Transaction failed, something went wrong";
           this.$store.state.snackbar = true;
        } finally {
          this.$store.state.loading = false;
         
        }
      }
    },
     async addToStake() {
      let allowance = await await this.$store.state.BREED.methods
        .allowance(this.currentAddress, utils.daoAddress)
        .call();
      allowance = await window.web3.utils.fromWei(
        allowance.toString(),
        "ether"
      );
      if(this.user.activeDeposit==0){

           
           this.$store.state.text = "You don't have any active stake,instead use 'Stake'  to activate new stake";
           this.$store.state.color="red"
        this.$store.state.snackbar = true;
      }
      else if (this.amount == 0) {
        this.$store.state.color=""
        this.$store.state.text = "Amount should be more than 0";
        this.$store.state.snackbar = true;
      } else if (allowance < this.amount) {
        this.$store.state.color=""
        this.$store.state.text =
          "Please approve the specified amount to stake the tokens. Use 'Approve' button to do it";
        this.$store.state.snackbar = true;
      } 
      else if(this.$store.state.breedBalance<this.amount){
        this.$store.state.color="red"
        this.$store.state.text="you don't have enough yBREE tokens";
        this.$store.state.snackbar=true;
        }
        else if (allowance >= this.amount) {
        try {
          this.$store.state.loading = true;
          let amount = await window.web3.utils.toWei(
            this.amount.toString(),
            "ether"
          );
          let done = await this.$store.state.DAO.methods
            .addToStake(amount)
            .send({ from: this.currentAddress });
          await this.$store.dispatch('setStakeDetails');
          this.$store.state.timer=! this.$store.state.timer
          this.dialog=false;
          this.$store.state.color = "green";
          this.$store.state.text = "Transaction completed successfully";
          this.$store.state.snackbar = true;
        } catch (err) {
          console.log(err);
          this.$store.state.color = "red";
          this.$store.state.text = "Transaction failed, you don't have any active stake.";
          this.$store.state.snackbar = true;
        } finally {
          this.$store.state.loading = false;
         
        }
      }
    },
  },
  async created() {
    this.currentAddress = this.$store.state.currentAddress;
    this.user=await this.$store.state.DAO.methods.users(this.currentAddress,utils.breedAddress).call();
    this.user.activeDeposit=parseFloat(await window.web3.utils.fromWei(this.user.activeDeposit.toString(),'ether'));
    
  },
};
</script>
