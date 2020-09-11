<template>
  <v-card class="mx-auto" height="270" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <ZapIcon size="0.8x" class="custom-class mr-1"></ZapIcon><span class="font-weight-light" style="font-size: 17px;">BALANCE</span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light my-2 px-7" style="font-size: 18px">
      <v-select
        :items="items"
       
        v-model="selected"
        item-text="name"
        item-value="address"
       itemtype="object"
        @change="changeToken"
        
        dense
        outlined
      >
        <template  v-slot:selection="{ item, index, select, selected }">
          <div class="d-flex">
            <img  :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px;"></img>
            <label class="mt-1">{{item.name}}</label>
          </div>
        </template>
        <template v-slot:item="{ item }">
          <div class="d-flex">
            <img :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px"></img>
            <label>{{item.name}}</label>
          </div>
        </template>
      </v-select>
      <p class="ma-0">{{balance}} {{symbol}} <span @click="changeToken" style="position:relative;bottom:2px;cursor:pointer"><v-icon>mdi-refresh</v-icon></span></p>
    </v-card-text>
    <hr class="hr-styles" />
    <v-card-actions style="padding:16px;">
      <v-dialog v-model="dialog" width="500">
        <template v-slot:activator="{ on, attrs }">
          <v-btn
            style="font-size: 12px; width: 145px"
            color="primary"
            v-bind="attrs"
            v-on="on"
            class="px-10 ml-2"
            elevation="0"
            dark
          >
            <CheckIcon size="1.2x" class="ml-10"></CheckIcon> <span class="ml-4 pr-10 text-caption">Start Farming</span>
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
              <div class="d-block mt-10">
                <div class="d-flex">
                  <v-select
                    :items="items"
                    v-model="selected"
                    dense
                    @change="changeToken"
                    item-text="name"
                    item-value="address"
                    outlined
                    label="Select Asset"
                  >
                    <template v-slot:selection="{ item, index, select }">
                      <div class="d-flex">
                        <img :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px"></img>
                        <label class="mt-1">{{item.name}}</label>
                      </div>
                    </template>
                    <template v-slot:item="{item}">
                      <div class="d-flex">
                        <img :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px"></img>
                        <label>{{item.name}}</label>
                      </div>
                    </template>
                  </v-select>
                  <v-btn height="40px" class="ml-1 btn-bg" @click="approve" outlined>Approve</v-btn>
                  <v-tooltip  max-width="200px" transition="scroll-y-transition" bottom>
                    <template v-slot:activator="{ on, attrs }">
                      <p class="mr-2 mt-n2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-1" style="color: #ABACAE"></InfoIcon></p>
                    </template>
                    <small>You will need to approve each of your governance asset to interact with the BREE farming contract. You only need to do this once for all governance assets.</small>
                  </v-tooltip>
                </div>
                <div class="d-flex">
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
                  <v-btn height="40px" width="100px" class="ml-1 btn-bg" @click="amount = balance" outlined>All</v-btn>
                </div>
              </div>
            </v-container>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <div class="d-flex flex-wrap">
              <v-btn
                class="mx-2 btn-bg"
                @click.prevent="farm"
                outlined
              >Start
              </v-btn>
              <v-tooltip  max-width="200px" transition="scroll-y-transition" bottom>
                <template v-slot:activator="{ on, attrs }">
                  <p class="mr-2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
                </template>
                <small>This should only be used if you do not already have an actively farming balance for the selected governance asset.</small>
              </v-tooltip>
              <v-btn
                class="mx-2"
                color="primary"
                elevation="0"
                @click.prevent="addToFarm"
                style="font-size: 12px"
              >Add More
              </v-btn>
              <v-tooltip transition="scroll-y-transition" bottom max-width="200px">
                <template v-slot:activator="{ on, attrs }">
                  <p class="mr-2"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
                </template>
                <small>This should only be used if you already have an actively farming balance for the selected governance asset and you wish to add more.</small>
              </v-tooltip>
            </div>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-card-actions>
  </v-card>
</template>

<script>
import utils from "../../utils/abi"
import { CheckIcon, ZapIcon, InfoIcon } from "vue-feather-icons";
  export default {
    components: {
      CheckIcon,
      ZapIcon,
      InfoIcon
    },
    data: () => ({
      dialog: false,
      contract:undefined,
      amount:0,
      balance:0,
      symbol:'',
      currentAddress:undefined,
      items: utils.items,
      selected:undefined
    }),
    methods:{

      async changeToken(e){
        try{
       this.$store.state.loading=true;
        console.log(this.selected)
        this.contract=await new window.web3.eth.Contract(utils.ycrvAbi,this.selected);
      let balance=await this.contract.methods.balanceOf(this.currentAddress).call();
      balance=await window.web3.utils.fromWei(balance.toString(),'ether');
      this.balance=balance;
      this.symbol=await this.contract.methods.symbol().call();
       this.$store.state.loading=false;
        }
        catch(err){
          console.log("error here:",err)
        }
        finally{
           this.$store.state.loading=false;
        }
      },
      async approve() {
      let bal = await this.contract.methods
        .balanceOf(this.currentAddress)
        .call();
      this.balance = await window.web3.utils.fromWei(bal.toString(), "ether");
      if (this.amount == 0) {
        this.$store.state.text = "Amount should be more than 0";
       this.$store.state.snackbar = true;
      } else if (this.balance < this.amount) {
       this.$store.state.color="red"
        this.$store.state.text =
          `You don't have enough ${this.symbol} tokens to stake the specified amount.`;
          this.$store.state.snackbar = true;
        return;
      } else if (this.balance >= this.amount) {
        try {
          this.$store.state.loading = true;
          let amount = await window.web3.utils.toWei(
            this.amount.toString(),
            "ether"
          );

          let done = await this.contract.methods
            .approve(utils.daoAddress, amount)
            .send({ from: this.currentAddress });
         this.$store.state.color = "green";
          this.$store.state.text = "Transaction completed successfully";
          this.$store.state.snackbar = true;
        } catch (err) {
          console.log(erappror);
          this.$store.state.color = "red";
           this.$store.state.text = "Transaction failed, something went wrong";
          this.$store.state.snackbar = true;
        } finally {
          this.$store.state.loading = false;
        }
      }
    },
    async farm() {
      let allowance = await this.contract.methods
        .allowance(this.currentAddress, utils.daoAddress)
        .call();
      allowance = await window.web3.utils.fromWei(
        allowance.toString(),
        "ether"
      );
        let amt= await window.web3.utils.toWei(this.amount.toString(),'ether');
           let activeFarmDeposit = await this.$store.state.DAO.methods
      .activeFarmDeposit(this.selected, this.currentAddress)
      .call();
      activeFarmDeposit = await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether")
    
      if(parseInt(activeFarmDeposit)>0){

           
           this.$store.state.text = "You already have active farm,instead use 'add more'  to increase your active farm";
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
          "Please approve the specified amount to farm the tokens. Use 'Approve' button to do it";
        this.$store.state.snackbar = true;
      }
      else if(this.balance<this.amount){
        this.$store.state.color="red"
        this.$store.state.text=`you don't have enough ${this.symbol} tokens`;
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
            .FARM(this.selected,amount)
            .send({ from: this.currentAddress });
             let contract= await new window.web3.eth.Contract(utils.ycrvAbi,this.selected);
      let balance=await contract.methods.balanceOf(this.currentAddress).call();
      balance=await window.web3.utils.fromWei(balance.toString(),'ether');
      this.balance=balance;
        // await this.$store.dispatch('setFarmDetails');
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

        async addToFarm() {
      let allowance = await this.contract.methods
        .allowance(this.currentAddress, utils.daoAddress)
        .call();
      allowance = await window.web3.utils.fromWei(
        allowance.toString(),
        "ether"
      );
        let amt= await window.web3.utils.toWei(this.amount.toString(),'ether');
        
           let activeFarmDeposit = await this.$store.state.DAO.methods
      .activeFarmDeposit(this.selected, this.currentAddress)
      .call();
      activeFarmDeposit = parseInt(await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether"))
      if(activeFarmDeposit==0){

           
           this.$store.state.text = "You don't have active farm, instead use 'Start'  to activate new farm";
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
          "Please approve the specified amount to farm the tokens. Use 'Approve' button to do it";
        this.$store.state.snackbar = true;
      }
      else if(this.balance<this.amount){
        this.$store.state.color="red"
        this.$store.state.text=`you don't have enough ${this.symbol} tokens`;
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
            .addToFarm(this.selected,amount)
            .send({ from: this.currentAddress });
         let contract= await new window.web3.eth.Contract(utils.ycrvAbi,this.selected);
      let balance=await contract.methods.balanceOf(this.currentAddress).call();
      balance=await window.web3.utils.fromWei(balance.toString(),'ether');
      this.balance=balance;
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
    },
    async created() {
      try{
      this.selected=this.items[0].address
      console.log(this.selected)
      this.currentAddress=this.$store.state.currentAddress

      // let yCrvBalance= await state.YCRV.methods.balanceOf(state.currentAddress).call();
      // yCrvBalance=await window.web3.utils.fromWei(yCrvBalance.toString(),'ether');
     this.contract= await new window.web3.eth.Contract(utils.ycrvAbi,this.selected);
      let balance=await this.contract.methods.balanceOf(this.currentAddress).call();
      balance=await window.web3.utils.fromWei(balance.toString(),'ether');
      this.balance=balance;
      this.symbol=await this.contract.methods.symbol().call();
     // console.log(contract)
     
    //   var paymentEvent =  await this.$store.state.DAO.events.TokenAdded({fromBlock:0},
    //    async (error, result) => {
    //  if(result){
    //                 console.log(result)
    //  }            
    //  else{
    //    console.log(error)
    //  }
    // });
      this.currentAddress=this.$store.state.currentAddress;
      }
      catch(err){
        console.log("Here 372:",err)
      }
      
    }
  }
  
</script>
