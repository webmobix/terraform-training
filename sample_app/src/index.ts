import express, { Express, Request, Response } from "express";

const app: Express = express();
const port = process.env.PORT || 3000;

// remove for v1
app.use(express.static("public"));

app.get("/", (req: Request, res: Response) => {
  res.send("Hello World!");
});

app.get("/env", (req: Request, res: Response) => {
  res.json(process.env);
});

app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
});
