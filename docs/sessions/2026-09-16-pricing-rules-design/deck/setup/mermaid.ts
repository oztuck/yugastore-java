import { defineMermaidSetup } from '@slidev/types'

// Mermaid cannot read CSS variables, so the diagram palette is repeated here.
// Keep these in step with styles/tokens.css when re-skinning.
const palette = {
  panel: '#1e293b',
  border: '#7dd3fc',
  text: '#e5e7eb',
  line: '#94a3b8',
  bg: '#0b1020',
  noteBg: '#3b2f00',
  noteBorder: '#fbbf24',
  noteText: '#fde68a',
}

export default defineMermaidSetup(() => ({
  theme: 'base',
  themeVariables: {
    fontSize: '15px',
    primaryColor: palette.panel,
    primaryBorderColor: palette.border,
    primaryTextColor: palette.text,
    lineColor: palette.line,
    edgeLabelBackground: palette.bg,
    // sequence diagrams
    actorBkg: palette.panel,
    actorBorder: palette.border,
    actorTextColor: palette.text,
    signalColor: palette.line,
    signalTextColor: palette.text,
    noteBkgColor: palette.noteBg,
    noteBorderColor: palette.noteBorder,
    noteTextColor: palette.noteText,
    // class diagrams
    classText: palette.text,
  },
}))
