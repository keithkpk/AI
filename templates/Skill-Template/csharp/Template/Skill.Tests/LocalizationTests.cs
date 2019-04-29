namespace $safeprojectname$
{
    [TestClass]
    public class LocalizationTests : SkillTestBase
    {
        [TestMethod]
        public async Task Test_Localization_Spanish()
        {
            CultureInfo.CurrentUICulture = new CultureInfo("es-mx");

            await GetTestFlow()
                .Send(new Activity()
                {
                    Type = ActivityTypes.ConversationUpdate,
                    MembersAdded = new List<ChannelAccount>() { new ChannelAccount("bot") }
                })
                .AssertReply(activity =>
                {
                    var messageActivity = activity.AsMessageActivity();
                    CollectionAssert.Contains(ParseReplies(MainResponses.WelcomeMessage, new StringDictionary()), messageActivity.Text);
                })
                .StartTestAsync();
        }

        [TestMethod]
        public async Task Test_Localization_German()
        {
            CultureInfo.CurrentUICulture = new CultureInfo("de-de");

            await GetTestFlow()
                .Send(new Activity()
                {
                    Type = ActivityTypes.ConversationUpdate,
                    MembersAdded = new List<ChannelAccount>() { new ChannelAccount("bot") }
                })
                .AssertReply(activity =>
                {
                    var messageActivity = activity.AsMessageActivity();
                    CollectionAssert.Contains(ParseReplies(MainResponses.WelcomeMessage, new StringDictionary()), messageActivity.Text);
                })
                .StartTestAsync();
        }

        [TestMethod]
        public async Task Test_Localization_French()
        {
            CultureInfo.CurrentUICulture = new CultureInfo("fr-fr");

            await GetTestFlow()
                .Send(new Activity()
                {
                    Type = ActivityTypes.ConversationUpdate,
                    MembersAdded = new List<ChannelAccount>() { new ChannelAccount("bot") }
                })
                .AssertReply(activity =>
                {
                    var messageActivity = activity.AsMessageActivity();
                    CollectionAssert.Contains(ParseReplies(MainResponses.WelcomeMessage, new StringDictionary()), messageActivity.Text);
                })
                .StartTestAsync();
        }

        [TestMethod]
        public async Task Test_Localization_Italian()
        {
            CultureInfo.CurrentUICulture = new CultureInfo("it-it");

            await GetTestFlow()
                .Send(new Activity()
                {
                    Type = ActivityTypes.ConversationUpdate,
                    MembersAdded = new List<ChannelAccount>() { new ChannelAccount("bot") }
                })
                .AssertReply(activity =>
                {
                    var messageActivity = activity.AsMessageActivity();
                    CollectionAssert.Contains(ParseReplies(MainResponses.WelcomeMessage, new StringDictionary()), messageActivity.Text);
                })
                .StartTestAsync();
        }

        [TestMethod]
        public async Task Test_Localization_Chinese()
        {
            CultureInfo.CurrentUICulture = new CultureInfo("zh-cn");

            await GetTestFlow()
                .Send(new Activity()
                {
                    Type = ActivityTypes.ConversationUpdate,
                    MembersAdded = new List<ChannelAccount>() { new ChannelAccount("bot") }
                })
                .AssertReply(activity =>
                {
                    var messageActivity = activity.AsMessageActivity();
                    CollectionAssert.Contains(ParseReplies(MainResponses.WelcomeMessage, new StringDictionary()), messageActivity.Text);
                })
                .StartTestAsync();
        }

    }
}
