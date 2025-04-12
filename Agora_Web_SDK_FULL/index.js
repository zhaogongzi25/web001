 


// create Agora client

AgoraRTC.setLogLevel(2);

//window.sayHello();

client=AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });



// 提前注册 first-video-frame 回调


 
var remoteUsers = {};
// Agora client options
var options = {
  appid: "6b96cf211c6746d98639d027191f87ba",
  channel: "1001",
  uid: null,
  token: null
};



// the demo can auto join channel with params in url
$(() => {
  var urlParams = new URL(location.href).searchParams;

  options.appid = urlParams.get("appid");
  options.channel = urlParams.get("channel");
 
  options.token = "";
  if (options.appid && options.channel) {
    $("#appid").val(options.appid);
    $("#token").val(options.token);
    $("#channel").val(options.channel);

    if(urlParams.get("isfirst")=="1"){
      console.log("《---这就是非常标记第一次进来直接加入房间---》");
      $("#join-form").submit();
      
    }
 
  }
})

$("#join-form").submit(async function (e) {
  e.preventDefault();
 
  try {
    await join();
  } catch (error) {
    console.error(error);
  } finally {

  }
})
function sendmsgtoflutter(msg){
  window.parent.postMessage( msg, "*");
}

async function join() {

  client.on("user-published", handleUserPublished);
  client.on("user-unpublished", handleUserUnpublished);
  // 监听连接状态变化
  client.on("connection-state-change", (curState, prevState) => {
    //  console.log(`连接状态从 ${prevState} 变为 ${curState}`);
     sendmsgtoflutter({ response: 'connection-state-change', channel: options.channel , connection: [curState,prevState]});
  });
 
  // 监听其他用户加入房间
  client.on("peer-online", (evt) => {
    console.log("新用户加入房间:", evt.uid);
  });

  // 监听其他用户离开房间
  client.on("peer-leave", (evt) => {
    console.log("用户离开房间:", evt.uid);
  });


     uid=await client.join(options.appid, options.channel, options.token || null);
    
     if(uid>0){
      sendmsgtoflutter({ response: 'uid-join-channel', channel: options.channel, uid: uid });
     }else{
      console.log("加入房间失败所有没有创建自己的uid");
     }

     
 
  
 
 
}


async function leave() {
  client.leave();
 
}

window.addEventListener("message", function (event) {
  console.log("webjs read message from Flutter:", event.data);
    if(event&&event.data&&event.data.action){
         console.log("--------------------------");
         console.log( "---当 webjs前页 的频道--",options.channel,"--所能接收到flutter发送过来的数据页id--",options.channel,"--");

        if (event.data.action=="leave"){
              console.log("应该要离开的频道页面--》",event.data.lastusechannel);
          if (event.data.channel==options.channel){
             console.log("确定现在要离开",options.channel)
               client.leave();
            }
        }
         if (event.data.action=="join"){
              if (event.data.channel==options.channel){
                  console.log("确定要加入房间",options.channel);
                 $("#join-form").submit();
             }
         }

    }
    console.log("---");
    console.log("---");





  });


async function subscribe(user, mediaType) {
  const uid = user.uid;
  // subscribe to a remote user
  await client.subscribe(user, mediaType);
 
  if (mediaType === 'video') {
    const player = $(`
      <div id="player-wrapper-${uid}">
        <div id="player-${uid}" class="player"></div>
      </div>
    `);
    $("#remote-playerlist").append(player);
    user.videoTrack.play(`player-${uid}`);
    // 监听远程视频轨道的首帧渲染事件
    user.videoTrack.on("first-frame-decoded", () => {
      console.log("远程视频首帧已解码！");
      var msg={ response: 'first-frame-decoded', channel: options.channel };
      sendmsgtoflutter(msg);
 
    
    });
  }
  if (mediaType === 'audio') {
    user.audioTrack.play();
  }
}

function handleUserPublished(user, mediaType) {
  const id = user.uid;
  remoteUsers[id] = user;
  subscribe(user, mediaType);

  if (mediaType === "video") {
  
  }
}

function handleUserUnpublished(user) {

  const id = user.uid;
  delete remoteUsers[id];
  $(`#player-wrapper-${id}`).remove();

  console.log("主播离开房间:", user.uid);
  sendmsgtoflutter({ response: 'anchor-leave-channel', channel: options.channel,uid: user.uid });

  
}

 