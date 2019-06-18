<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>{{ site.github.project_title }}</title>
        <description>Feed of production updates to Caffeinator.</description>
        <language>en</language>
        {% for release in site.github.releases %}
            {% unless release.draft or release.prerelease %}
                <item>
                    <title>{{ release.name }}</title>
                    <description><![CDATA[{{ release.body | markdownify }}]]></description>
                    <pubDate>{{ release.published_at | date_to_rfc822 }}</pubDate>
                    {% for asset in release.assets limit:1 %}
                        <enclosure
                        url="{{ asset.browser_download_url }}"
                        sparkle:version="{{ release.tag_name | remove_first:'v' }}"
                        length="{{ asset.size }}"
                        type="application/octet-stream" />
                    {% endfor %}
                </item>
            {% endunless %}
        {% endfor %}
    </channel>
</rss>
