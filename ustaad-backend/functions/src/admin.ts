import * as admin from "firebase-admin";
import { FieldValue, GeoPoint, Query } from "firebase-admin/firestore";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export { admin, FieldValue, GeoPoint, Query };