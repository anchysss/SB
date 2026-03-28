import { useState, useRef } from 'react'
import { uploadFile } from '../api'

export default function FileUpload({ folder, accept, label, onUploaded, className = '' }) {
  const [uploading, setUploading] = useState(false)
  const [fileName, setFileName] = useState('')
  const [error, setError] = useState('')
  const inputRef = useRef()

  const handleChange = async (e) => {
    const file = e.target.files[0]
    if (!file) return
    setFileName(file.name)
    setError('')
    setUploading(true)
    try {
      const { s3_url, key } = await uploadFile(file, folder)
      onUploaded({ s3_url, key, name: file.name })
    } catch (err) {
      setError(err.message)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className={className}>
      <button
        type="button"
        onClick={() => inputRef.current?.click()}
        disabled={uploading}
        className="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg text-sm text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 transition"
      >
        {uploading ? (
          <span className="animate-spin h-4 w-4 border-2 border-gray-400 border-t-transparent rounded-full" />
        ) : (
          <span>📎</span>
        )}
        {uploading ? 'Uploading…' : label || 'Choose file'}
      </button>
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        className="hidden"
        onChange={handleChange}
      />
      {fileName && !uploading && (
        <p className="mt-1 text-xs text-gray-500 truncate">{fileName}</p>
      )}
      {error && <p className="mt-1 text-xs text-red-500">{error}</p>}
    </div>
  )
}
