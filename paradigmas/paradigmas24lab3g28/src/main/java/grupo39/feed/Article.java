package grupo39.feed;

public class Article {

    private String title;
    private String description;
    private String link;
    private String pubDate;

    public Article(String title, String description, String link, String pubDate) {
        this.title = title;
        this.description = description;
        this.link = link;
        this.pubDate = pubDate;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getLink() {
        return link;
    }

    public String getPubDate() {
        return pubDate;
    }

    public void printArticle() {
        System.out.println("Title: " + title);
        if (!description.equals("")) {
            System.out.println("Description: " + description);
        } else {
            System.out.println("Description: No description available");
        }
        System.out.println("PubDate: " + pubDate);
        System.out.println("Link: " + link);
        System.out.println("*".repeat(120));
    }
}
