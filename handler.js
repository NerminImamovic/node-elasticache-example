const Redis = require("ioredis");

module.exports.getPrices = async (event) => {
  const { REDIS_PORT, REDIS_HOST, PRICES_API_URL } = process.env;

  const client = new Redis({
    port: REDIS_PORT,
    host: REDIS_HOST,
  });
  try {
    client.on("error", (err) => console.log("Redis Client Error", err));
    client.on("connect", () => console.log("Redis Client Connected"));

    const cachedData = await client.get("data");

    if (cachedData) {
      console.log("Data found in cache");

      return {
        statusCode: 200,
        body: JSON.stringify(
          {
            message: "Success",
            response: JSON.parse(cachedData),
          },
          null,
          2
        ),
      };
    }
    
    const response = await fetch(PRICES_API_URL);

    const data = await response.json();

    await client.set("data", JSON.stringify(data));

    console.log("Data written to cache");

    await client.disconnect();

    return {
      statusCode: 200,
      body: JSON.stringify(
        {
          message: "Success",
          response: data,
        },
        null,
        2
      ),
    };
  } catch (error) {
    console.log(error);

    return {
      statusCode: 200,
      body: JSON.stringify(
        {
          message: "Error",
          response: error.message,
        },
        null,
        2
      ),
    };
  }
};
