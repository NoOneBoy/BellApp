import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, TokenMessage } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

initializeApp();

/**
 * FCM solo-data de alta prioridad. El audio con la app cerrada lo reproduce
 * RingForegroundService. El canal nativo `bell_ring` es el respaldo si Android
 * degrada la prioridad y no deja arrancar el servicio.
 */
export const onRingCreated = onDocumentCreated(
  {
    document: "rooms/{roomId}/rings/{ringId}",
    region: "us-central1",
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      return;
    }

    const roomId = event.params.roomId;
    const ringId = event.params.ringId;
    const fromUid = String(data.fromUid ?? "");

    const members = await getFirestore()
      .collection("rooms")
      .doc(roomId)
      .collection("members")
      .get();

    const tokens: string[] = [];
    for (const member of members.docs) {
      if (member.id === fromUid) continue;
      if (member.data().leftAt) continue;
      const token = member.data().fcmToken as string | undefined;
      if (token) tokens.push(token);
    }

    if (tokens.length === 0) {
      logger.info("No peer tokens for ring", { roomId, ringId });
      return;
    }

    const messages: TokenMessage[] = tokens.map((token) => ({
      token,
      data: {
        type: "ring",
        ringId,
        roomId,
        channelId: "bell_ring",
      },
      android: {
        priority: "high",
        ttl: 60 * 1000,
        directBootOk: true,
        restrictedPackageName: "com.sara.bellapp",
      },
    }));

    const response = await getMessaging().sendEach(messages);
    logger.info("FCM ring dispatched", {
      roomId,
      ringId,
      success: response.successCount,
      failure: response.failureCount,
    });
  },
);
