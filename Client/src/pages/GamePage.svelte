<script lang="ts">
  import Canvas from '../components/canvas.svelte';
  import Chat from '../components/Chat.svelte';
  import Button from '../components/Button.svelte';
  import { Modal } from 'carbon-components-svelte';
  import { fade, fly } from 'svelte/transition';
  export const location = null;
  import socket from '../socket';
  import { writable } from 'svelte/store';
  import { setContext } from 'svelte';
  export let gameId;
  const gameSocket = socket('game:' + gameId);
  console.log(gameSocket);

  let name = '';
  export const nameStore = writable('');
  setContext('name', nameStore);

  function joinGame() {
    nameStore.set(name);
    //validate name
    if (name.length === 0) {
      alert('please name yourself');
      return;
    }
    gameSocket.push('join-game', { name });
    name = '';
  }
</script>

<div class="flex items-center justify-around box-border h-40 ml-80">
  <div class="flex items-center animate-bouncer font-logo h-40 ">
    {#each 'picture' as char, i}
      <p
        class="text-10xl"
        in:fade={{ delay: 1000 + i * 150, duration: 1500 }}
        out:fly={{ y: -20, duration: 1000 }}
      >
        {char}
      </p>
    {/each}
  </div>
  <div class="flex items-center animate-bouncey font-logo h-40 border-2 ">
    {#each 'this' as char, i}
      <p
        class=" text-10xl"
        in:fade={{ delay: 2000 + i * 150, duration: 1500 }}
        out:fly={{ y: -20, duration: 1000 }}
      >
        {char}
      </p>
    {/each}
  </div>
</div>
<div class="h-820px w-full flex items-center justify-center pt-52">
  <div class="flex justify-center gap-5 items-start h-1000px">
    <div class="flex justify-center gap-5">
      <Modal
        class="flex justify-center gap-5"
        size="xs"
        modalHeading="Enter name to join game"
        primaryButtonDisabled
        open
        on:closed
      >
        <input type="text" placeholder="" bind:value={name} />
        <Button on:message={joinGame} name="Enter Name" />
      </Modal>
    </div>

    <Canvas {gameSocket} />
    <Chat {gameSocket} />
  </div>
</div>
