import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  title: 'MetricSpaces.jl',
  description: "A Julia package for working with metric spaces",
  lastUpdated: true,
  cleanUrls: true,
  outDir: 'REPLACE_ME_DOCUMENTER_VITEPRESS', // This is required for MarkdownVitepress to work correctly.

  head: [
    ['link', { rel: 'icon', href: 'REPLACE_ME_DOCUMENTER_VITEPRESS_FAVICON' }]
  ],

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"
    }
  },

  themeConfig: {
    outline: 'deep',
    logo: { src: 'REPLACE_ME_DOCUMENTER_VITEPRESS_LOGO', width: 24, height: 24 },
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting_started' },
      { text: 'API Reference', link: '/api' }
    ],

    sidebar: [
      {
        text: 'Documentation',
        items: [
          { text: 'Home', link: '/' },
          { text: 'Mathematical Background', link: '/mathematical_background' },
          { text: 'Getting Started', link: '/getting_started' },
          { text: 'Core Types', link: '/types' },
          { text: 'Distance Functions', link: '/distances' },
          { text: 'Metric Balls', link: '/balls' },
          { text: 'Sampling Methods', link: '/sampling' },
          { text: 'Neighborhood Analysis', link: '/neighborhoods' },
          { text: 'Datasets', link: '/datasets' },
          { text: 'API Reference', link: '/api' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/JuliaTDA/MetricSpaces.jl' }
    ],

    footer: {
      message: 'Made with <a href="https://github.com/LuxDL/DocumenterVitepress.jl" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `Copyright © ${new Date().getFullYear()} G. Vituri and contributors.`
    }
  }
})
