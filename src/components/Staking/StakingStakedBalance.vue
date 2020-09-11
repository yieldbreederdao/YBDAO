<template>
  <v-card class="mx-auto" height="220px" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <ZapIcon size="0.8x" class="custom-class mr-1"></ZapIcon><span class="font-weight-light" style="font-size: 17px;">STAKED BALANCE</span>
    </v-card-title>
    <hr class="hr-styles" />
   
    <!-- <h6 class="font-weight-light mx-7 mt-2 mb-0 pb-0" style="font-size: 18px">
      <p v-if="ended!=true && user.lastClaimedDate>0" class=" caption">Expires in : {{days}} d : {{hours}} h : {{mins}} m : {{secs}} s</p>
      <p v-else-if="user.lastClaimedDate > 0 && ended==true">Expired</p>
       {{$store.state.totalStakedMe}}
     
    </h6> -->
    
    <div v-if="user.activeDeposit==0" :class="{'stake-cards':!$vuetify.theme.dark,'stake-cards-light':$vuetify.theme.dark}"  class="font-weight-light px-7 py-3 ma-2 stake-cards">
     
      <!-- <br> -->
     
         {{$store.state.totalStakedMe}} YBREE
     
      
    </div>
    <div v-else-if="user.activeDeposit>0" :class="{'stake-cards':!$vuetify.theme.dark,'stake-cards-light':$vuetify.theme.dark}"  class="font-weight-light px-7 py-1 ma-2">
     
      <!-- <br> -->
     
        
     <p v-if="ended!=true && user.activeDeposit>0"  class="caption mb-0 mt-0 pt-0 pb-0">Expires in : {{days}} d : {{hours}} h : {{mins}} m : {{secs}} s</p>
      <p v-else-if="ended===true && user.activeDeposit>0">Expired</p>
       {{$store.state.totalStakedMe}} YBREE
   
      
    </div>
   
    <!-- <p class="font-weight-light mx-7 pb-0 mb-0" style="font-size:18px;">  YBREE</p> -->
  
    <hr class="hr-styles" />
     <div class="pa-4 d-flex">
      <v-btn @click="withdraw" :disabled=disabled class="ma-2" color="primary" elevation="0" style="font-size: 12px; width: 145px">
        <CornerUpRightIcon size="1.2x" class="custom-class ml-3"></CornerUpRightIcon> <span class="ml-4 mr-5">WITHDRAW</span>
      </v-btn>
      <v-tooltip  max-width="200px" bottom>
        <template v-slot:activator="{ on, attrs }">
          <p class="mt-n1"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
        </template>
        <small>You can only withdraw your staked balance once the default lock-in period has ended.</small>
      </v-tooltip>
    </div>
  </v-card>
</template>
<script>
import utils from "../../utils/abi"
import { ZapIcon, CornerUpRightIcon, InfoIcon } from 'vue-feather-icons'
  export default {
    components: {
      ZapIcon,
      CornerUpRightIcon,
      InfoIcon
    },
    data: () => ({
      currentAddress:undefined,
      disabled:true,
      balance:0,
      days:0,
      hours:0,
      mins:0,
      secs:0,
      ended:undefined,
      user:{
        lastClaimedDate:"",
      }

    }),
    
    methods:{
        async withdraw(){
        try{
          if(this.$store.state.totalStakedMe<=0){
            this.$store.state.text="You don't have any staked tokens to withdraw";
             this.$store.state.snackbar=true;
            return;
          }
          this.$store.state.loading=true
          let claim=await this.$store.state.DAO.methods.ClaimStakedTokens().send({from:this.currentAddress});
          await this.$store.dispatch('setStakeDetails');
          this.$store.state.timer= !this.$store.state.timer;
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
          this.$store.state.color="";
        
        }
      },
      async timer(){
          this.user=await this.$store.state.DAO.methods.users(this.currentAddress,utils.breedAddress).call();
          console.log("User details:",this.user);
         this.user.activeDeposit= parseInt(this.user.activeDeposit);
         this.user.lastClaimedDate=parseInt(this.user.lastClaimedDate);
        let totalTime=parseInt(this.user.startTime)+parseInt(this.user.period);
        console.log("total time:",totalTime)
        let day,mins,hour,secs=0;
        if (totalTime * 1000 > new Date().getTime()) {
          console.log("Timer started")
        // console.log(index + ":" + totalTime);
        let timee = setInterval(() => {
          
          let min = new Date().getTime();
          //console.log("total time of " + index + ":" + totalTime);
          //min = parseInt(min / 1000);
          let remainTime = totalTime * 1000 - min;
          // console.log(index+":"+remainTime)
          //remainTime=parseInt(remainTime/1000);
          //console.log(parseInt(min / 1000));
          day = parseInt(remainTime / (1000 * 60 * 60 * 24));
          hour = parseInt(
            (remainTime % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
          );
          //console.log("hour:" + hour);
          mins = parseInt((remainTime % (1000 * 60 * 60)) / (1000 * 60));
          //console.log("mins:" + mins);
          secs = parseInt((remainTime % (1000 * 60)) / 1000);
          //console.log("secs of " + index + ":" + secs);
          // console.log("secs:" + this.secs);
          // else if(remainTime<=-1 && totalTime*100 < new Date().getTime() && this.details[index].ended==true && this.details[index].lastEnded==true){
          //   lastEnded=false
          //   clearInterval(timee);
          // }
          if (remainTime <= -1) {
            console.log("ended")
            //console.log("remain time:",remainTime)
            clearInterval(timee);
            
            this.ended=true;
            day = -1;
            mins = -1;
            secs = -1;
            hour = -1;
            this.disabled=false;
          }
          this.days = day;
          this.mins = mins;
          this.secs = secs;
          this.hours = hour;
          
        }, 1000);
      } else {
       console.log("Ended");
        this.ended = true;
        //console.log("Ended:", this.details[index].ended);
      }
      }
    },
    async mounted(){
        await this.timer();
    },
    async created() {
     //this.$store.state.loading=true;
      this.currentAddress=this.$store.state.currentAddress
       //await this.timer();
       
       
    //     var stakeEvent =  await this.$store.state.DAO.events.Staked({filter:{staker:this.currentAddress},fromBlock:"latest"},
    //    async (error, result) => {
    //  if(result){
    //                 console.log(result)
          
    //                await this.timer();
    //  }            
    //  else{
    //    console.log(error)
    //  }
    // });
    // var addStakeEvent =  await this.$store.state.BREED.events.Transfer({filter:{from:this.currentAddress},fromBlock:"latest"},
    //    async (error, result) => {
    //  if(result){
    //                 console.log(result)
          
    //                 await this.timer();
    //  }            
    //  else{
    //    console.log(error)
    //  }
    // });
   
   // this.$store.state.loading=false;
     
    }
  }
</script>