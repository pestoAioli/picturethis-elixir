<script>
  export let gameSocket;
  import { onMount } from 'svelte';
  import Button from '../components/Button.svelte';
  let penColor;
  let painting;
  let canvas;
  let ctx;
  let isDrawing = false;
  let secretWord;
  let winner;
  let lineWidth = 5;
  gameSocket.on('draw-replay', ({ mousePosition, lineWidth, penColor }) => {
    draw(mousePosition, lineWidth, penColor, false);
  });
  gameSocket.on('prompt', ({ drawer, prompt }) => {
    console.log('DRAWER', prompt);
    isDrawing = true;
    secretWord = prompt;
  });
  gameSocket.on('round-over', () => {
    isDrawing = false;
    clear(false);
    winner = false;
  });
  gameSocket.on('clear-game', (e) => {
    clear(false);
  });
  gameSocket.on('winner', ({ player_name }) => {
    winner = player_name;
  });
  gameSocket.on('finished-position', () => finishedPosition(false));
  $: time = 60;

  onMount(() => {
    canvas = document.getElementById('myCanvas');
    ctx = canvas.getContext('2d');
    canvas.height = 500;
    canvas.width = 800;
    canvas.addEventListener('touchstart', startPosition);
    canvas.addEventListener('touchend', finishedPosition);
    canvas.addEventListener('touchmove', handleDraw);
  });
  function startGame() {
    gameSocket.push('start');
  }
  // const gameTimer = setInterval(() => {
  //     time = time - 1;
  //     if (time === 0) {
  //       time = 60;
  //       // alert('round over');
  //       clearInterval(gameTimer);
  //       return;
  //     }
  //   }, 1000);

  function startPosition(e) {
    painting = true;
    console.log('startposition');
  }

  function finishedPosition(broadcast) {
    painting = false;
    ctx.beginPath();
    if (broadcast) gameSocket.push('finished-position');
    console.log('finishedposition');
  }

  function getMousePosition(e) {
    var mouseX = ((e.offsetX * canvas.width) / canvas.clientWidth) | 0;
    var mouseY = ((e.offsetY * canvas.height) / canvas.clientHeight) | 0;
    return { x: mouseX, y: mouseY };
  }

  function handleDraw(e) {
    if (!painting) return;
    const mousePosition = getMousePosition(e);
    console.log('drawing', e);
    draw(mousePosition, lineWidth, penColor, true);
  }

  function draw(mousePosition, lineWidth, penColor, broadcast) {
    ctx.lineWidth = lineWidth;
    ctx.strokeStyle = penColor;
    ctx.lineCap = 'round';
    ctx.lineTo(mousePosition.x, mousePosition.y);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(mousePosition.x, mousePosition.y);
    if (broadcast) gameSocket.push('draw', { mousePosition, lineWidth, penColor });
  }

  function clear(broadcast) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    canvas.height = 500;
    canvas.width = 800;
    if (broadcast) gameSocket.push('clear');
  }
</script>

<div>
  <div>
    {#if winner}
      <p>{winner} is your champion</p>
    {/if}
  </div>
  <canvas
    class="bg-white border-4 border-solid border-black rounded-md shadow-69xl block h-canvas w-canvas"
    id="myCanvas"
    on:mousemove={isDrawing ? handleDraw : null}
    on:mousedown={isDrawing ? startPosition : null}
    on:mouseup={isDrawing ? () => finishedPosition(true) : null}
  />

  <div class="flex gap-4 items-center h-12 mt-8">
    <!-- <p>{time}</p> -->
    <button on:click={clear} class="h-16 w-36 text-white bg-blue-500 rounded-lg flex justify-center items-center hover:cursor-pointer hover:bg-red-500 active:bg-green-400">Clear</button>
    <button on:click={startGame} class="h-16 w-36 text-white bg-blue-500 rounded-lg flex justify-center items-center hover:cursor-pointer hover:bg-red-500 active:bg-green-400">Start Game</button>
    <input class="h-8" type="color" bind:value={penColor} />
    <input type="range" min="1" max="10" bind:value={lineWidth} />
    <div>
      {#if isDrawing}
        <p>your secret word is: {secretWord}</p>
      {/if}
    </div>
  </div>
</div>

<style>
</style>
