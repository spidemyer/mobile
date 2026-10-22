const { initializeApp } = require("firebase-admin/app");
const { FieldValue, getFirestore } = require("firebase-admin/firestore");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");

initializeApp();

const db = getFirestore();

exports.updateUserBookStats = onDocumentWritten(
  {
    document: "users/{userId}/books/{bookId}",
    region: "us-central1",
    retry: true,
  },
  async (event) => {
    const { userId } = event.params;
    const booksSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("books")
      .get();

    let livrosLidos = 0;
    let paginasLidas = 0;

    for (const book of booksSnapshot.docs) {
      const data = book.data();
      const pagesRead = Number(data.pagesRead);

      if (data.status === "Lidos") {
        livrosLidos += 1;
      }
      if (Number.isFinite(pagesRead)) {
        paginasLidas += pagesRead;
      }
    }

    await db
      .collection("users")
      .doc(userId)
      .collection("stats")
      .doc("general")
      .set({
        livrosLidos,
        paginasLidas,
        updatedAt: FieldValue.serverTimestamp(),
      });
  },
);
