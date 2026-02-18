# jimaku-sub-fetcher

<p align="center">
  <a href="#requirements">requirements</a> •
  <a href="#installation">installation</a> •
  <a href="#usage">usage</a> •
  <a href="#remap-key">remap</a> •
  <a href="#how-it-works">how works</a>
</p>

---

mpv script to fetch and sync subtitles from [jimaku.cc](https://jimaku.cc).

## Requirements

- [mpv](https://mpv.io/)
- [guessit](https://github.com/guessit-io/guessit)
- [ffsubsync](https://github.com/smacke/ffsubsync)
- `curl`

## Installation

1. **Clone** this script to your mpv scripts directory:
   ```bash
   git clone -C ~/.config/mpv/scripts/ 'https://github.com/rodrigo-sys/jimaku-sub-fetcher'
   ```

2. **Set API key** as environment variable:
   ```bash
   export JIMAKU_API_KEY="your_api_key_here"
   ```
   
   Get your API key from [jimaku.cc](https://jimaku.cc).

## Usage

Press `Ctrl+j` to fetch and load subtitle

## Remap key

You can remap the key in your `input.conf`:

```
j script-binding jimaku-sub-fetcher
```

## How it works

The script parses the filename with guessit to extract title and episode, searches jimaku.cc for subtitles, downloads the first result to the video directory, syncs it with ffsubsync, then loads it into mpv.
