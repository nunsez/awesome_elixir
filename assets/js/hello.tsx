import { Component, createSignal } from "solid-js";
import { render as solidRender } from "solid-js/web";

import '../css/style.css';
import typescriptLogo from "/images/typescript.svg";
import viteLogo from "/images/vite.svg";
import { MountableElement } from "solid-js/web";

const Hello: Component = () => {
  const [count, setCount] = createSignal(0);

  const inc = () => setCount((prev) => prev + 1);
  
  return (
    <div>
      <a href="https://vitejs.dev" target="_blank">
        <img src={viteLogo} class="logo" alt="Vite logo" />
      </a>
      <a href="https://www.typescriptlang.org/" target="_blank">
        <img src={typescriptLogo} class="logo vanilla" alt="TypeScript logo" />
      </a>
      <h1>Vite + TypeScript</h1>
      <div class="card">
        <button id="counter" type="button" onClick={inc}>count is {count()}</button>
      </div>
      <p class="read-the-docs">
        Click on the Vite and TypeScript logos to learn more
      </p>
    </div>
  );
};

export const render = (element: MountableElement) => {
  solidRender(() => <Hello></Hello>, element);
};

export default Hello;
