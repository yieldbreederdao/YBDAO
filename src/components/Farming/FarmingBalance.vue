<template>
  <v-card class="mx-auto" height="270" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <CommandIcon size="0.8x" class="custom-class mr-1"></CommandIcon><span class="font-weight-light" style="font-size: 17px;">FARMING BALANCE</span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light my-2 px-7" style="font-size: 18px; height: 120px">
      <v-select @change="changeToken" :items="items" v-model="selected" item-text="name" item-value="address" dense outlined>
        <template v-slot:selection="{ item, index, select }">
          <div class="d-flex">
            <img :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px" />
            <label class="mt-1">{{item.name}}</label>
          </div>
        </template>
        <template v-slot:item="{item}">
          <div class="d-flex">
            <img :src="item.icon" class="mr-5 rounded-circle" style="max-width: 24px" />
            <label>{{item.name}}</label>
          </div>
        </template>
      </v-select>
      <p class="ma-0">{{balance}} {{symbol}} <span @click="changeToken" style="position:relative;bottom:2px;cursor:pointer"><v-icon>mdi-refresh</v-icon></span></p>
    </v-card-text>
    <hr class="hr-styles" />
    <v-card-actions  style="padding:16px;">
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
            <CornerUpRightIcon size="1.2x" class="custom-class ml-3"></CornerUpRightIcon> <span class="ml-4 mr-5 text-caption">Stop Farming</span>
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
                    @change="changeToken"
                    v-model="selected"
                    item-text="name"
                    item-value="address"
                    dense
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
          <v-card-actions class="mt-0">
            <v-spacer></v-spacer>
            <div class="d-flex flex-wrap">
              <v-btn
                class="mx-2"
                color="primary"
                elevation="0"
                @click.prevent="stopFarming"
                style="font-size: 12px"
              >Stop Farming
              </v-btn>
            </div>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-card-actions>
  </v-card>
</template>

<script>
import { CornerUpRightIcon, CommandIcon } from "vue-feather-icons";
import utils from '../../utils/abi';
export default {
  components: {
    CornerUpRightIcon,
    CommandIcon
  },
  data: () => ({
    balance: 0,
    amount:0,
    dialog: false,
    currentAddress:undefined,
    symbol:"",
    items: utils.items,
    selected:"0x000913Ac6DCc68533a0C667eeFC1ac1875E28F29"
    
    
  }),
  methods: {
     async changeToken(e){
        try{
       this.$store.state.loading=true;
       
         let activeFarmDeposit = await this.$store.state.DAO.methods
      .activeFarmDeposit(this.selected, this.currentAddress)
      .call();
      activeFarmDeposit = await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether")
     
      this.balance=activeFarmDeposit;
    
      this.items.filter(item=>{
        if(item.address==this.selected){
          this.symbol=item.name
        }
      })
       this.$store.state.currentTokenAddress=this.selected;
     await this.$store.dispatch('setFarmDetails')
       this.$store.state.loading=false;
        }
        catch(err){
          console.log(err)
        }
        finally{
           this.$store.state.loading=false;
        }
      },
    async stopFarming(){
 try{
          if(this.balance<=0){
            this.$store.state.text="You don't have any farmed tokens to withdraw";
             this.$store.state.snackbar=true;
            return;
          }
          else if(this.amount==0){
            this.$store.state.color=""
            this.$store.state.text = "Amount should be more than 0";
             this.$store.state.snackbar = true;
            return;
          }
          else if(this.amount>this.balance){
            this.$store.state.color="red";
             this.$store.state.text="Amount exceeds farmed token balance";
             this.$store.state.snackbar=true;
             return;
             
          }
          
          this.$store.state.loading=true
          let amt= await window.web3.utils.toWei(this.amount.toString(),'ether');
          let claim=await this.$store.state.DAO.methods.withdrawFarmedTokens(this.selected,amt).send({from:this.currentAddress});
           let activeFarmDeposit = await this.$store.state.DAO.methods
      .activeFarmDeposit(this.selected, this.currentAddress)
      .call();
      activeFarmDeposit = parseFloat(await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether"))
     
      this.balance=activeFarmDeposit;
          this.dialog=false;
          this.$store.state.color="green"
          this.$store.state.text="Transaction completed successfully"
          this.$store.state.snackbar=true;
          
        }catch(err){
          console.log(err);
            this.color="red"
          this.text="Transaction failed, something went wrong"
          this.snackbar=true;
        }
        finally{
          this.$store.state.loading=false;
          this.amount=0;
        }
    }
  },
  async created() {
    try{
    this.currentAddress = this.$store.state.currentAddress;
    console.log("address:",this.selected)
    this.$store.state.currentTokenAddress=this.selected
    
    let activeFarmDeposit = await this.$store.state.DAO.methods
      .activeFarmDeposit(this.selected, this.currentAddress)
      .call();
      activeFarmDeposit = await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether")
      this.balance=activeFarmDeposit;
       this.items.filter(item=>{
        if(item.address==this.selected){
          this.symbol=item.name
        }
      })
    }catch(err){
      console.log("Here 219:",err);
    }
  },
};
</script>
