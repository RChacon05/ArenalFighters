---
name: commit-pr-style
description: Use SIEMPRE que vayas a crear un commit o un Pull Request en ArenalFighters. Define el formato fijo (Conventional Commits, en inglés) y prohíbe la línea Co-Authored-By y cualquier footer de generación.
---

# commit-pr-style

Formato obligatorio para commits y PRs de ArenalFighters. Mantener consistencia hace el historial
legible y los reviews rápidos entre las dos pistas del equipo.

## Reglas que anulan el comportamiento por defecto

- **Todo en inglés** (título y cuerpo de commits y PRs).
- **NUNCA** agregar `Co-Authored-By: ...`.
- **NUNCA** agregar footers tipo `Generated with Claude Code` ni `🤖 ...`.
- Sin emojis en el título.

## Formato de commit

```
type(scope): subject

[optional body explaining what and why, wrapped at ~72 cols, in English]
```

### Reglas del título
- `type`: uno de `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `perf`, `style`.
- `scope`: el subsistema o spec afectado. Usar uno de:
  `sim`, `render`, `netcode`, `ui`, `menu`, `ai`, `data`, `signaling`, `docs`, `build`.
- `subject`: imperativo, minúscula inicial, sin punto final. Máx ~60 caracteres.
- Una sola idea por commit (commits chicos).

### Ejemplos correctos
```
feat(sim): add deterministic Simulation.advance
test(sim): add rollback save/restore regression
fix(render): correct facing flip when fighters overlap
docs(team): assign spec ownership between tracks
```

### Incorrectos
- `Added stuff` (sin type/scope, pasado, vago).
- `feat(sim): Add Simulation.` (mayúscula, punto final).
- Cualquier commit con `Co-Authored-By` o footer de generación.

## Formato de Pull Request

**Título:** misma convención que el commit (`type(scope): subject`).

**Cuerpo (en inglés), con estas secciones:**

```markdown
## Summary
One or two sentences: what this PR does and why.

## Changes
- Bullet list of the concrete changes.

## Spec
Which spec/plan this advances (e.g. Spec 01 — deterministic sim).

## Testing
How it was verified. For simulation changes, state that
`replay-determinism-tester` passes and paste the test summary line.

## Notes
Anything the reviewer should know (follow-ups, known gaps). Optional.
```

### Reglas del PR
- La rama sigue el naming de `docs/TEAM.md` (`spec-NN-...`, `signaling-server`, etc.).
- Lo revisa la otra persona antes de mergear.
- Si toca la simulación, no se mergea con los tests de determinismo en rojo.

## Antes de ejecutar `git commit` o crear el PR

1. ¿Título en inglés, `type(scope): subject`, imperativo, sin punto?
2. ¿Cuerpo en inglés y sin `Co-Authored-By` ni footers de generación?
3. ¿El PR tiene las secciones Summary / Changes / Spec / Testing?
