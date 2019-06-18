<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>{{ site.github.project_title }}</title>
        <description>Feed of production updates to Caffeinator.</description>
        <language>en</language>
        {% for release in site.github.releases %}
            {% assign num_assets = release.assets | size %}
            {% unless num_assets < 2 or release.draft or release.prerelease %}
                <item>
                    <title>{{ release.name }}</title>
                    <description><![CDATA[{{ release.body | markdownify }}]]></description>
                    <pubDate>{{ release.published_at | date_to_rfc822 }}</pubDate>
                    {% assign zips = release.assets | where:"content_type","application/zip" %}
                    {% for asset in zips limit:1 %}
                            <enclosure
                            url="{{ asset.browser_download_url }}"
                            {% assign version = release.tag_name | remove_first:'v' %}
                            sparkle:version="{{ version }}"
                            sparkle:edSignature="{{ site.data.signatures[version] }}"
                            length="{{ asset.size }}"
                            type="{{ asset.content_type }}" />
                    {% endfor %}
                </item>
            {% endunless %}
        {% endfor %}
    </channel>
</rss>
