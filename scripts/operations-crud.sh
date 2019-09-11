use retail;

db.inventory.insertMany([
   // MongoDB adds the _id field with an ObjectId if _id is not present
   { item: "journal", qty: 25, status: "A",
       size: { h: 14, w: 21, uom: "cm" }, tags: [ "blank", "red" ] },
   { item: "notebook", qty: 50, status: "A",
       size: { h: 8.5, w: 11, uom: "in" }, tags: [ "red", "blank" ] },
   { item: "paper", qty: 100, status: "D",
       size: { h: 8.5, w: 11, uom: "in" }, tags: [ "red", "blank", "plain" ] },
   { item: "planner", qty: 75, status: "D",
       size: { h: 22.85, w: 30, uom: "cm" }, tags: [ "blank", "red" ] },
   { item: "postcard", qty: 45, status: "A",
       size: { h: 10, w: 15.25, uom: "cm" }, tags: [ "blue" ] }
]);

db.inventory.insertOne({item: "eraser"});

db.inventory.updateOne(
    {item: "eraser"},
    {
        $set: {size: {h: 4, l: 2, w: 1, uom: "cm"}},
        $currentDate: {lastModified: true}
    }
);

db.inventory.updateOne(
    {item: "eraser"},
    {
        $set: {
            status: "A",
            qty: 120,
            tags: ["blank", "red", "blue"]
        },
        $currentDate: {lastModified: true}
    }
);

db.inventory.updateMany(
    {"qty": { $lt: 50 } },
    {
        $set: {status: "P"},
        $currentDate: {lastModified: true}
    }
);

db.inventory.replaceOne(
    {item: "eraser"},
    {item: "eraser", instock: [
        {warehouse: "A", qty: 60},
        {warehouse: "B", qty: 70}
    ]}
);

db.inventory.update(
    {item: "eraser"},
    {item: "eraser", stock: 10, info: {manufacture: "PT. Indo Karya", country: "Indonesia"}}
);

db.inventory.update(
    {item: "bolpoint"},
    {item: "bolpoint", stock: 10, info: {manufacture: "PT. Indo Karya", country: "Indonesia"}},
    {upsert: true}
);

db.inventory.update(
    {item: "envelop"},
    {item: "envelop", stock: 10, info: {manufacture: "PT. Indo Karya", country: "Indonesia"}},
    {upsert: true}
);