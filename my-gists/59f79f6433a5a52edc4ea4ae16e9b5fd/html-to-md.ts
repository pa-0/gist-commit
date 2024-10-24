import { load } from 'cheerio'
import type { Browser, BrowserContext } from 'playwright'
import { firefox } from 'playwright'
import { NodeHtmlMarkdown } from 'node-html-markdown'

export type Webpage = {
  url: string
  html: string
  markdown: string
}

export class PageReader {
  private browser?: Browser
  private context?: BrowserContext

  async init() {
    this.browser = await firefox.launch({
      headless: true,
    })

    this.context = await this.browser.newContext()
  }

  async read(pageUrl: string, selector?: string) {
   
    const page = await this.context.newPage()

    try {
      await page.goto(pageUrl)

      const pageHtml = await page.evaluate(() => {
        return globalThis.document.documentElement.outerHTML
      })

      const contentHtml = this.sanitizeHtml(pageHtml, selector)

      return {
        url: pageUrl,
        html: contentHtml,
        markdown: NodeHtmlMarkdown.translate(contentHtml),
      }
    } finally {
      await page.close()
    }
  }

  async dispose() {
    if (this.context) {
      await this.context.close()
    }

    if (this.browser) {
      await this.browser.close()
    }
  }

  private sanitizeHtml(html: string, selector?: string) {
    const $ = load(html)

    if (selector) {
      const selectedHtml = $(selector).html()

      if (!selectedHtml || !selectedHtml.trim()) {
        throw new Error(`No content found for selector: ${selector}`)
      }

      return selectedHtml
    }

    $('script, style, path, footer, header, head').remove()

    return $.html()
  }
}

async function main() {
  const pageReader = new PageReader()

  await pageReader.init()

  const page = await pageReader.read(process.argv[2])

  await pageReader.dispose()

  console.log(page.markdown)
}

main()