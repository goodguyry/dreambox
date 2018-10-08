<?php
/**
 * The dreambox admin page.
 */

?>

<!doctype html>
<html lang="en-US">
  <head>
    <title>Dreambox</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
    body {
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      align-items: center;
      height: 100vh;
      font-family: monospace;
      font-size: large;
      color: black;
      padding: 1.25rem 0;
      margin: 0;
    }

    a {
      box-sizing: border-box;
      color: inherit;
      text-decoration: none;
      display: block;
    }

    a:hover,
    a:focus {
      text-decoration: underline;
    }

    div {
      box-sizing: border-box;
      width: 80%;
      max-width: 400px;
      margin-bottom: auto;
      display: flex;
      flex-direction: column;
      padding: 1rem;
      border: 1px solid;
    }

    @media (min-width: 600px) {
      div {
        width: 60%;
      }
    }

    @media (min-width: 900px) {
      div {
        width: 50%;
      }
    }

    ul {
      box-sizing: border-box;
      list-style: none;
      padding: 0;
      margin: 0;
    }

    .tools li {
      box-sizing: border-box;
      padding: 1rem 0;
    }

    .tools li::before {
      content: '-';
      float: left;
      margin-right: 0.625rem;
    }

    .repo-links {
      box-sizing: border-box;
      display: flex;
      justify-content: space-between;
      width: 100%;
    }

    @media (min-width: 600px) {
      .repo-links {
        width: 70%;
      }
    }

    @media (min-width: 900px) {
      .repo-links {
        width: 50%;
      }
    }

    .repo-links li {
      width: calc(100% / 3);
      text-align: center;
    }
    </style>
  </head>

  <body>
    <div>
      <h1># Dreambox Admin</h1>

      <ul class="tools">
        <li>
          <a href="/phpmyadmin/">phpMyAdmin</a>
        </li>
        <li>
          <a download href="/public/ca-chain.cert.pem">ca-chain.cert.pem</a>
        </li>
      </ul>
    </div>

    <ul class="repo-links">
      <li>
        <a href="https://github.com/goodguyry/dreambox/wiki">Wiki</a>
      </li>
      <li>
        <a href="https://github.com/goodguyry/dreambox/issues">Issues</a>
      </li>
      <li>
        <a href="https://github.com/goodguyry/dreambox/releases">Releases</a>
      </li>
    </ul>
  </body>
</html>
