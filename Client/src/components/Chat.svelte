<script>
  import { beforeUpdate, afterUpdate, getContext } from 'svelte';
  export let gameSocket;

  // enabling chat to autoscroll
  let scroll;
  let autoscroll;

  beforeUpdate(() => {
    autoscroll = scroll && scroll.offsetHeight + scroll.scrollTop > scroll.scrollHeight - 20;
  });

  afterUpdate(() => {
    if (autoscroll) scroll.scrollTo(0, scroll.scrollHeight);
  });

  let userInput = '';

  //testing of right guess mechanic
  let secretWord = 'Cheese';

  //hardcoded for now
  const playerName = 'Paula';

  //mock msgs
  let msgs = [];

  //mock timestamp
  let timestamp = 3;

  function handleKeydown(event) {
    if (event.key === 'Enter') {
      handleSubmit();
    }
  }
  const user = getContext('name');

  function handleSubmit() {
    console.log(user);
    //if user input is empty, do not add message
    if (userInput === '') {
      return;
    }
    timestamp++;
    //push guess/message to socket
    gameSocket.push('guess', { userInput, $user });
    userInput = '';
  }

  gameSocket.on('guess-message', (mzg) => {
    console.log('mzggg', mzg);
    msgs = [...msgs, { user: `🥹${$user}`, text: mzg.userInput }];
  });
</script>

<div
  class="flex flex-col h-600px w-96 border-4 border-solid border-black rounded-md shadow-69xl bg-white"
>
  <div
    class="h-600px w-96 text-left flex-auto overflow-y-auto flex flex-col items-end"
    bind:this={scroll}
  >
    <ul>
      {#each msgs as { user, text, guess }}
        {#if guess}
          <li class="text-green-400 break-all"><strong>{user}: </strong>{text}</li>
        {:else}
          <li class="break-all"><strong>{user}: </strong>{text} <span /></li>
        {/if}
      {/each}
    </ul>
  </div>

  <div>
    <input
      type="text"
      name=""
      id=""
      bind:value={userInput}
      placeholder="Type your message.."
      on:keydown={handleKeydown}
    />
    <input type="submit" value="Submit" on:click={handleSubmit} />
  </div>
</div>
