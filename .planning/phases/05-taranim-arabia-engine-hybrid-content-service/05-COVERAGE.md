# API Coverage — taranimarabia.org

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

| capability | decision | reason |
|---|---|---|
| search | INTEGRATE | Search hymns by title/keyword on taranimarabia.org |
| song_details | INTEGRATE | Fetch title, singer, album, author, composer, distributor metadata |
| mp3_stream | INTEGRATE | Direct MP3 audio stream URL extraction (`https://taranimarabia.org/music/{id}.mp3`) |
| lyrics | INTEGRATE | Parse full Arabic lyrics from `#words{id}` container |
| singers | INTEGRATE | Browse `/allsingers` directory and `/singer/{id}` artist song catalog |
| albums | INTEGRATE | Browse `/albums` directory and `/album/{id}` album tracklist |
| hymn_of_the_day | INTEGRATE | Extract featured daily hymn and artwork from homepage `.premium-item` |
| chords_and_sheet_music | INTEGRATE | Extract PDF chords and GIF sheet music links when available on song page |
