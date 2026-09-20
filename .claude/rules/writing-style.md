<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Writing style: no AI tells

Applies to every piece of prose a person reads: the pages under `content/`,
every Dutch string in `templates/`, `config.toml`, the README, the changelog,
the `docs/` pages, everything under `.claude/`, the comment lines of the shell
scripts, and every commit, pull request and issue body.

Write plainly, so the text reads like a person wrote it for another person.
This site has one director and a handful of pages; it does not need a voice.

## Which language

The split is by reader:

- **Dutch: everything a visitor reads.** `content/**`, the strings in
  `templates/**`, `config.toml`, `README.md`, `CHANGELOG.md`, `docs/**`, the
  page titles, the alt texts, the footer.
- **English: everything a developer reads.** Identifiers, template variable
  names, comment lines, commit messages, pull-request and issue text,
  `CLAUDE.md` and everything under `.claude/`.
- **English: what a CI run and a check script print.** Those lines are read
  while operating the repository, never while visiting the site, and they
  appear interleaved with GitHub's own output, which is English. A line
  becomes Dutch the moment a built page renders it.

A Dutch string never lives in a shell script, and an English string never
reaches a page.

## Banned tells

1. **The "not X, but Y" setup.** Do not frame a point as a contrast for
   effect. State what the thing is. A contrast is allowed only when the reader
   genuinely holds the wrong belief and the sentence corrects it with facts on
   both sides. In Dutch the same tell reads "niet X, maar Y".
2. **The rule of three.** Do not group adjectives or clauses into triads on a
   beat. A real list keeps its real length; a decorative triad gets cut to the
   one word that matters. On a services page this is the easiest tell to fall
   into and the one a reader notices first.
3. **Banned words and phrases, machine-checked.** None of the following
   appears in first-party prose, in either language.
   `scripts/checks/prose-style.sh` fails on any hit, per edit through the hook
   and in CI. The two lists below are the same list as in that script: add to
   both at once.
   - **High-frequency AI words:** delve, underscore (as a verb), pivotal,
     realm, harness (as a verb), illuminate, leverage, robust, elevate,
     testament to, landscape (as a metaphor), tapestry, foster, empower,
     unlock, holistic, synergy, journey (as a metaphor). Write: explore,
     highlight, important, area, use, explain, strong, improve, shows.
   - **Structured transitions:** "that being said", "at its core", "to put it
     simply", "simply put", "a key takeaway", "from a broader perspective",
     "it is worth noting", "in today's", "at the end of the day", "imagine a
     world", "in conclusion". Open with the subject of the sentence.
   - **Hedges:** "generally speaking", "broadly speaking", "typically", "tends
     to", "arguably", "to some extent". State the fact, or name the exception.
   - **Academic verbs:** shed light on, facilitate, refine, bolster,
     differentiate, streamline. Write: explain, help, improve, support,
     distinguish, simplify.
   - **Buzzwords:** revolutionize, innovative, cutting-edge, game-changing,
     transformative, seamless, scalable solution, state-of-the-art. Cut the
     word and give the specific fact instead.
   - **Dutch equivalents, banned the same way:** duiken in, onderstrepen,
     cruciaal, sleutelrol, naadloos, robuust, krachtig, faciliteren, in kaart
     brengen, stroomlijnen, innovatief, baanbrekend, revolutionair,
     transformatief, "dat gezegd hebbende", "in de kern", "simpel gezegd",
     "kort gezegd", "eenvoudig gezegd", "over het algemeen", doorgaans, "in
     zekere mate", "tot op zekere hoogte", "vanuit een breder perspectief",
     "een belangrijke les", "werpt licht op", belichten, landschap (als
     metafoor), holistisch, synergie, schaalbare oplossing. Schrijf: lezen,
     benadrukken, belangrijk, sterk, helpen, uitleggen, meestal, vaak.

   The guard skips fenced code and quoted lines (`> …`), so a quotation from a
   source is never rewritten to pass.
4. **The em dash habit.** Do not use em dashes to attach explanatory clauses.
   Almost every one is a comma, a period, parentheses, or a colon. This is the
   most common tell, so check every one. Prefer "16 to 32 GB" over an en-dash
   range in prose. Keep hyphens in flags (`--locked`) and compound words. In
   Dutch the gedachtestreepje used as clause glue is the same tell.
5. **Vague transitions and filler openings.** Open with the subject of the
   sentence.
6. **Adverb tics and hedging.** Cut "quietly", "genuinely", "simply",
   "notably", "importantly" when they add nothing.
7. **The TED-talk tone.** No inspirational build-ups, no rhetorical questions
   for effect.
8. **The mission statement.** A paragraph that sounds like a principle and
   carries no fact reads as a machine wrote it, because the reader cannot
   check it, act on it, or learn anything from it. The test is one question
   per sentence: **can a reader verify this?** A date, a number, a name, a
   file path, an article of law all pass. A characterisation of how good the
   work is does not. This matters most on the pages a prospective client
   reads: "wij bouwen software" with a concrete example beats any sentence
   about quality. Where there is little to say, say little.
9. **Bold-formatting overuse.** Bold a term once where it is defined, not
   throughout for emphasis.

## How to write instead

- Address the reader as "je" in Dutch, "you" in English. Not "we" about the
  reader, and never "de gebruiker".
- Use active voice. Name who does what.
- Use present tense.
- Keep sentences short, near 25 words. If a clause can be deleted and the
  sentence still reads, delete it.
- Prefer concrete nouns and numbers to adjectives. On the site that means a
  year, a city, a service, a way of working, and what happens in the first
  week of a project.

## Enforcement

The word list and the em dash are machine-enforced:
`scripts/checks/prose-style.sh` runs per edit
(`.claude/hooks/prose_style_guard.sh`) and in CI over every tracked markdown
file, every template, `config.toml`, and the comment lines of the shell
scripts and the stylesheet. Issue and pull-request text goes through `gh`,
which the guard does not see: hold it to the same list by hand. The rest of
this file is review-enforced.

## Sources

- Google developer documentation style guide: <https://developers.google.com/style>
- Wikipedia, "Signs of AI writing" (the community tell list).
