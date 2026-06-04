import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { supabase } from '../../lib/supabase'
import type { Session, User } from '@supabase/supabase-js'

/* ------------------------------------------------------------------ */
/* Provider: auth state only                                          */
/* ------------------------------------------------------------------ */

interface AuthCtx {
  session: Session | null
  user: User | null
  loading: boolean
  signOut: () => Promise<void>
}

const Ctx = createContext<AuthCtx | undefined>(undefined)

export function useAuth() {
  const ctx = useContext(Ctx)
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>')
  return ctx
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let mounted = true

    // 1) Read whatever is already in storage. Resolves `loading` on first paint.
    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return
      setSession(data.session)
      setLoading(false)
    })

    // 2) Stay in sync. Callback is sync — no await, no supabase.* calls here.
    //    If you ever NEED to call supabase from a state change, defer it:
    //    setTimeout(() => { /* supabase.* here */ }, 0)
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, newSession) => {
      if (!mounted) return
      setSession(newSession)
      setLoading(false)
    })

    return () => {
      mounted = false
      subscription.unsubscribe()
    }
  }, [])

  const signOut = async () => {
    await supabase.auth.signOut()
    // No navigate() — onAuthStateChange emits SIGNED_OUT, the guard redirects.
  }

  return (
    <Ctx.Provider
      value={{ session, user: session?.user ?? null, loading, signOut }}
    >
      {children}
    </Ctx.Provider>
  )
}

/* ------------------------------------------------------------------ */
/* Guard: protect routes that require a logged-in user                */
/*   Wrap protected routes:  <RequireAuth><Dashboard /></RequireAuth>  */
/* ------------------------------------------------------------------ */

export function RequireAuth({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) return <FullScreenSpinner /> // replace with your splash/skeleton

  if (!user) {
    // Remember where they were headed so /auth can send them back.
    return <Navigate to="/auth" replace state={{ from: location }} />
  }

  return <>{children}</>
}

/* ------------------------------------------------------------------ */
/* Onboarding decision: /plan (has profile) vs /questions (no profile)*/
/*   Put this on a neutral landing route (e.g. index "/" and "/auth"  */
/*   for already-logged-in users). It runs the profile check ONCE,    */
/*   OUTSIDE the auth callback, so awaiting supabase here is safe.     */
/* ------------------------------------------------------------------ */

export function PostAuthRouter() {
  const { user, loading } = useAuth()
  const [target, setTarget] = useState<string | null>(null)

  useEffect(() => {
    if (loading || !user) return
    let cancelled = false

    supabase
      .from('user_profiles')
      .select('user_id')
      .eq('user_id', user.id)
      .maybeSingle()
      .then(({ data, error }) => {
        if (cancelled) return
        // On error, fall through to onboarding rather than trapping the user.
        setTarget(data && !error ? '/plan' : '/questions')
      })

    return () => {
      cancelled = true
    }
  }, [loading, user])

  if (loading) return <FullScreenSpinner />
  if (!user) return <Navigate to="/auth" replace />
  if (!target) return <FullScreenSpinner /> // checking profile
  return <Navigate to={target} replace />
}

/* Replace with your real loader. */
function FullScreenSpinner() {
  return <div style={{ display: 'grid', placeItems: 'center', height: '100vh' }}>Loading…</div>
}