// Import the functions you need from the SDK
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth"; // For authentication
import { getFirestore, doc, setDoc } from "firebase/firestore"; // For Firestore

// Your Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDzxQqzw3eEyZBwlRbZRIAwRn3PPo66gU8",
  authDomain: "steamy-book.firebaseapp.com",
  projectId: "steamy-book",
  storageBucket: "steamy-book.firebasestorage.app",
  messagingSenderId: "509474815476",
  appId: "1:509474815476:web:11604ac88fe2534a018da1",
  measurementId: "G-LS1M88EDH8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

// Initialize Firebase Auth
const auth = getAuth(app);

// Initialize Firestore
const db = getFirestore(app);

// Example Firebase Auth function: Sign in with email and password
async function signInWithEmail(email, password) {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    console.log("Signed in user:", user);
  } catch (error) {
    console.error("Error signing in:", error);
  }
}

// Example Firestore function: Set document in Firestore
async function setUserData(userId, data) {
  try {
    const docRef = doc(db, "users", userId);
    await setDoc(docRef, data);
    console.log("Document written!");
  } catch (error) {
    console.error("Error writing document:", error);
  }
}
