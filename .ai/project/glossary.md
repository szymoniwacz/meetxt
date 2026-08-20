# Glossary

## Terms

### First useful version

`meetxt transcribe meeting.mp3` reliably creates a readable timestamped `meeting.md`, or returns an actionable error without unsafe side effects.

### Source audio

An existing local MP3, M4A, or WAV meeting recording supplied by the user.

### Transcript segment

Provider-returned text associated with a start time and rendered as one timestamped Markdown block.

### Provider adapter

The small component containing OpenAI-specific transcription behavior and translating provider results/failures into MeetXT concepts.

### Local-first

Input and output are local files, although transcription requires uploading audio to the configured external provider.

### Atomic output

Writing either creates the complete transcript or leaves no partial output file.
