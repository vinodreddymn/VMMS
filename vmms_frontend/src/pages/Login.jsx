import React, { useState } from 'react'
import api from '../api/axios'
import useAuthStore from '../store/auth.store'
import { useNavigate } from 'react-router-dom'

import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import TextField from '@mui/material/TextField'
import Button from '@mui/material/Button'
import Paper from '@mui/material/Paper'
import Divider from '@mui/material/Divider'
import Chip from '@mui/material/Chip'
import InputAdornment from '@mui/material/InputAdornment'
import LockIcon from '@mui/icons-material/Lock'
import PersonIcon from '@mui/icons-material/Person'
import SecurityIcon from '@mui/icons-material/Security'

export default function Login() {
	const [username, setUsername] = useState('')
	const [password, setPassword] = useState('')
	const [loading, setLoading] = useState(false)
	const loginStore = useAuthStore()
	const navigate = useNavigate()

	async function handleSubmit(e) {
		e.preventDefault()
		setLoading(true)
		try {
			const res = await api.post('/auth/login', { username, password })
			const token = res?.data?.token
			const apiUser = res?.data?.user || null

			let user = apiUser
			if (!user && token) {
				const payload = JSON.parse(atob(token.split('.')[1]))
				user = { id: payload.id, role: payload.role, username }
			}

			if (!token || !user) {
				throw new Error('Invalid login response')
			}

			loginStore.login(token, user)
			navigate('/')
		} catch (err) {
			console.error(err)
			alert(err?.response?.data?.message || err?.message || 'Login failed')
		} finally {
			setLoading(false)
		}
	}

	return (
		<Box
			sx={{
				minHeight: '100vh',
				display: 'flex',
				background:
					'linear-gradient(135deg, #081a33 0%, #0f2a5a 45%, #1e3a8a 100%)',
				color: '#fff',
			}}
		>
			{/* LEFT: LOGIN PANEL */}
			<Box
				sx={{
					width: { xs: '100%', md: '38%' },
					display: 'flex',
					alignItems: 'center',
					justifyContent: 'center',
					p: 4,
					position: 'relative',
				}}
			>
				<Paper
					elevation={12}
					sx={{
						width: '100%',
						maxWidth: 420,
						borderRadius: 3,
						p: 4,
						background: 'rgba(255,255,255,0.97)',
						backdropFilter: 'blur(8px)',
						border: '1px solid rgba(15,42,90,0.2)',
					}}
				>
					<Box sx={{ textAlign: 'center', mb: 3 }}>
						<SecurityIcon sx={{ fontSize: 42, color: '#1e3a8a', mb: 1 }} />
						<Typography variant="h5" sx={{ fontWeight: 800 }}>
							INS RAJALI
						</Typography>
						<Typography variant="subtitle2" color="text.secondary">
							Naval Airfield Visitor Management System
						</Typography>
					</Box>

					<Divider sx={{ mb: 3 }}>
						<Chip label="SECURE LOGIN" size="small" />
					</Divider>

					<form onSubmit={handleSubmit}>
						<TextField
							fullWidth
							label="Username"
							value={username}
							onChange={(e) => setUsername(e.target.value)}
							required
							margin="normal"
							InputProps={{
								startAdornment: (
									<InputAdornment position="start">
										<PersonIcon />
									</InputAdornment>
								),
							}}
						/>

						<TextField
							fullWidth
							label="Password"
							type="password"
							value={password}
							onChange={(e) => setPassword(e.target.value)}
							required
							margin="normal"
							InputProps={{
								startAdornment: (
									<InputAdornment position="start">
										<LockIcon />
									</InputAdornment>
								),
							}}
						/>

						<Button
							fullWidth
							type="submit"
							variant="contained"
							disabled={loading}
							sx={{
								mt: 3,
								py: 1.4,
								fontWeight: 700,
								letterSpacing: 0.5,
								background:
									'linear-gradient(90deg,#1e3a8a,#2563eb)',
								boxShadow: '0 8px 22px rgba(30,64,175,0.35)',
							}}
						>
							{loading ? 'Authenticating...' : 'SECURE SIGN IN'}
						</Button>
					</form>

					<Typography
						variant="caption"
						sx={{
							display: 'block',
							mt: 3,
							textAlign: 'center',
							color: 'text.secondary',
						}}
					>
						Authorized Naval Personnel Only • All access is monitored
					</Typography>
				</Paper>
			</Box>

			{/* RIGHT: HERO VISUAL / VIDEO */}
			<Box
				sx={{
					display: { xs: 'none', md: 'block' },
					width: '62%',
					position: 'relative',
					backgroundImage:
						'url("https://images.unsplash.com/photo-1541410965313-d53b3c16ef17?q=80&w=1600&auto=format&fit=crop")',
					backgroundSize: 'cover',
					backgroundPosition: 'center',
				}}
			>
				{/* Dark overlay */}
				<Box
					sx={{
						position: 'absolute',
						inset: 0,
						background:
							'linear-gradient(90deg, rgba(8,26,51,0.9) 0%, rgba(8,26,51,0.4) 60%, rgba(8,26,51,0.8) 100%)',
					}}
				/>

				{/* Overlay Content */}
				<Box
					sx={{
						position: 'absolute',
						bottom: 60,
						left: 60,
						maxWidth: 520,
						color: '#e6ecff',
					}}
				>
					<Box
						component="video"
						autoPlay
						muted
						loop
						playsInline
						sx={{
							display: { xs: 'none', md: 'block' },
							width: '62%',
							objectFit: 'cover',
						}}
						src="/assets/naval_airfield.mp4"
						/>
					<Typography variant="h3" sx={{ fontWeight: 800, mb: 2 }}>
						INS RAJALI
					</Typography>
					<Typography
						variant="h6"
						sx={{ lineHeight: 1.5, opacity: 0.9 }}
					>
						Secure Naval Airfield Access Control & Visitor Processing System
						designed for high-security maritime aviation operations.
					</Typography>

					<Typography
						variant="body2"
						sx={{ mt: 2, opacity: 0.8 }}
					>
						Real-time gate clearance • Personnel authentication •
						Airfield operational security
					</Typography>
				</Box>
			</Box>
		</Box>
	)
}
