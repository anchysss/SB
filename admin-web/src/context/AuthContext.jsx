import { createContext, useContext, useEffect, useState } from 'react'
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth'
import { auth } from '../firebase'
import { getWriter, getWriters } from '../api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [profile, setProfile] = useState(null) // writer profile if writer role
  const [role, setRole] = useState(null)        // 'admin' | 'writer'
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser)
      if (firebaseUser) {
        await resolveRole(firebaseUser)
      } else {
        setRole(null)
        setProfile(null)
      }
      setLoading(false)
    })
    return unsub
  }, [])

  async function resolveRole(firebaseUser) {
    try {
      // Check custom claims first
      const token = await firebaseUser.getIdTokenResult()
      if (token.claims?.role === 'admin') {
        setRole('admin')
        setProfile(null)
        return
      }
      // Try to find writer by email
      const writers = await getWriters()
      const writerList = writers.writers || []
      const found = writerList.find(
        (w) => w.email?.toLowerCase() === firebaseUser.email?.toLowerCase()
      )
      if (found) {
        setRole('writer')
        setProfile(found)
      } else {
        // Fallback: treat as admin if no writer record found
        setRole('admin')
        setProfile(null)
      }
    } catch (err) {
      console.error('resolveRole error:', err)
      setRole('admin') // fallback
    }
  }

  const login = (email, password) => signInWithEmailAndPassword(auth, email, password)
  const logout = () => signOut(auth)

  return (
    <AuthContext.Provider value={{ user, role, profile, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
