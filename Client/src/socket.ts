import { Socket } from 'phoenix';

const socket = (channelTopic) => {
  let socket = new Socket('ws://a576-45-130-134-153.ngrok.io/socket', {
    params: { token: sessionStorage.userToken },
  });
  socket.connect();
  // Now that you are connected, you can join channels with a topic.
  // Let's assume you have a channel with a topic named `cursor` and the
  // subtopic is its id - in this case lobby:
  let channel = socket.channel(channelTopic, {});
  channel
    .join()
    .receive('ok', (resp) => {
      console.log('Joined successfully', resp);
    })
    .receive('error', (resp) => {
      console.log('Unable to join', resp);
    });
  // const presence = new Presence(channel);
  // presence.onSync(() => {
  //   const ul = document.createElement('ul');
  //   presence.list((name, { metas: [firstDevice] }) => {
  //     console.log(firstDevice);
  //   });
  //   document.getElementById('cursor-list').innerHTML = ul.innerHTML;
  // });

  return channel;
};

export default socket;
