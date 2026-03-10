import React from "react"
import { createRoot } from "react-dom/client"
import { BrowserRouter } from "react-router-dom"
import { CssBaseline, GlobalStyles } from "@mui/material"
import App from "./App"

const root = createRoot(document.getElementById("root"))

root.render(
  <React.StrictMode>
    <BrowserRouter>

      {/* Remove browser default spacing */}
      <CssBaseline />

      <GlobalStyles
        styles={{
          html: {
            height: "100%",
            width: "100%",
            overflow: "hidden"
          },
          body: {
            height: "100%",
            width: "100%",
            margin: 0,
            padding: 0,
            overflow: "hidden"
          },
          "#root": {
            height: "100%",
            width: "100%",
            overflow: "hidden",
            display: "flex"
          },
          "*": {
            boxSizing: "border-box"
          }
        }}
      />

      <App />

    </BrowserRouter>
  </React.StrictMode>
)