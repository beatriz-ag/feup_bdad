PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS User (
    name TEXT UNIQUE NOT NULL,
    CONSTRAINT UserPK PRIMARY KEY (name) 
);

CREATE TABLE IF NOT EXISTS Organization (
    name TEXT UNIQUE NOT NULL,
    CONSTRAINT OrganizationPK PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS OrganizationMemberVisibility (
    user TEXT,
    organization TEXT,
    isPrivate INT CHECK (isPrivate >= 0 AND isPrivate <= 1),
    CONSTRAINT OrganizationMemberVisibilityPK PRIMARY KEY (user, organization),
    CONSTRAINT OrganizationMemberVisibilityUserFK FOREIGN KEY (user) REFERENCES User(name),
    CONSTRAINT OrganizationMemberVisibilityOrganizationFK FOREIGN KEY (organization) REFERENCES Organization(name)
);

CREATE TABLE IF NOT EXISTS Team (
    name TEXT NOT NULL,
    description TEXT,
    CONSTRAINT TeamPK PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS TeamRole (
    user TEXT,
    team TEXT,
    isMaintainer INT CHECK (isMaintainer >= 0 AND isMaintainer <= 1),
    CONSTRAINT TeamRolePK PRIMARY KEY (user, team),
    CONSTRAINT TeamRoleUserFK FOREIGN KEY (user) REFERENCES User(name),
    CONSTRAINT TeamRoleTeamFK FOREIGN KEY (team) REFERENCES Team(name)
);

/* Repos & Stuff */

CREATE TABLE IF NOT EXISTS Repository (
    ID INT CHECK (ID >= 1),
    name TEXT NOT NULL,
    rootDirectory INT,
    defaultBranch TEXT,
    visibility INT CHECK (visibility >= 0 AND visibility <= 1),
    CONSTRAINT RepositoryPK PRIMARY KEY (ID),
    CONSTRAINT RepositoryRootFK FOREIGN KEY (rootDirectory) REFERENCES Directory(ID),
    CONSTRAINT RepositoryDefaultBranchFK FOREIGN KEY (defaultBranch) REFERENCES Branch(name)
);

CREATE TABLE IF NOT EXISTS Submodule (
    source INT,
    destination INT, 
    CONSTRAINT SubmodulePK PRIMARY KEY (source, destination),
    CONSTRAINT SubmoduleSourceFK FOREIGN KEY (source) REFERENCES Repository(ID),
    CONSTRAINT SubmoduleDestinationFK FOREIGN KEY (destination) REFERENCES Repository(ID)
);

CREATE TABLE IF NOT EXISTS OwnerRepository (
    user TEXT,
    repository INT,
    CONSTRAINT OwnerRepositoryPK PRIMARY KEY (user, repository),
    CONSTRAINT OwnerRepositoryUserFK FOREIGN KEY (user) REFERENCES User(name),
    CONSTRAINT OwnerRepositoryRepositoryFK FOREIGN KEY (repository) REFERENCES Repository(ID)
);

CREATE TABLE IF NOT EXISTS ContributorRepository (
    user TEXT,
    repository INT,
    CONSTRAINT ContributorRepositoryPK PRIMARY KEY (user, repository),
    CONSTRAINT ContributorRepositoryUserFK FOREIGN KEY (user) REFERENCES User(name),
    CONSTRAINT ContributorRepositoryRepositoryFK FOREIGN KEY (repository) REFERENCES Repository(ID)
);

/* Git Stuff */

CREATE TABLE IF NOT EXISTS Branch (
    name TEXT NOT NULL,
    repository INT,
    CONSTRAINT BranchPK PRIMARY KEY (name, repository),
    CONSTRAINT BranchRepositoryFK FOREIGN KEY (repository) REFERENCES Repository(ID)
);

CREATE TABLE IF NOT EXISTS "Commit" (
    ID INT, 
    commitHash CHAR(40) NOT NULL,
    message TEXT,
    CONSTRAINT CommitPK PRIMARY KEY (ID),
    CONSTRAINT CommitContributionFK FOREIGN KEY (ID) REFERENCES Contribution(ID)
);

CREATE TABLE IF NOT EXISTS Tag (
    name TEXT NOT NULL,
    "commit" INT,
    CONSTRAINT TagPK PRIMARY KEY (name, "commit"),
    CONSTRAINT TagCommitFK FOREIGN KEY ("commit") REFERENCES "Commit"(ID)
);

/* Contributions */

CREATE TABLE IF NOT EXISTS Contribution (
    ID INT CHECK (id >= 1),
    user TEXT,
    repository INT,
    date DATE,
    CONSTRAINT ContributionPK PRIMARY KEY (ID),
    CONSTRAINT ContributionUserFK FOREIGN KEY (user) REFERENCES User(name),
    CONSTRAINT ContributionRepositoryFK FOREIGN KEY (repository) REFERENCES Repository(ID)
);

CREATE TABLE IF NOT EXISTS PullRequest (
    ID INT,
    pullRequestNumber INT CHECK (pullRequestNumber >= 1),
    status INT CHECK (status >= 0 AND status <= 1),
    message TEXT,
    CONSTRAINT PullRequestPK PRIMARY KEY (ID),
    CONSTRAINT PullRequestContributionFK FOREIGN KEY (ID) REFERENCES Contribution(ID)
);

CREATE TABLE IF NOT EXISTS Issue (
    ID INT, 
    issueNumber INT CHECK (issueNumber >= 1),
    message TEXT,
    CONSTRAINT IssuePK PRIMARY KEY (ID),
    CONSTRAINT IssueContributionFK FOREIGN KEY (ID) REFERENCES Contribution(ID)
);

CREATE TABLE IF NOT EXISTS Merge (
    ID INT CHECK (ID >= 1),
    oursName TEXT,
    oursRepository INT,
    theirsName TEXT,
    theirsRepository INT,
    CONSTRAINT MergePK PRIMARY KEY (ID),
    CONSTRAINT MergeCommitFK FOREIGN KEY (ID) REFERENCES "Commit"(ID),
    CONSTRAINT MergeBranchOursNameFK FOREIGN KEY (oursName, oursRepository) REFERENCES Branch(name, repository),
    CONSTRAINT MergeBranchTheirsNameFK FOREIGN KEY (theirsName, theirsRepository) REFERENCES Branch(name, repository),
    CONSTRAINT MergeSameRepository CHECK (oursRepository == theirsRepository),
    CONSTRAINT MergeDifferentBranches CHECK(oursName <> theirsName)
);

/* Files And Directories */

/* Still Missing The Checks for prohibited chars in folders */

CREATE TABLE IF NOT EXISTS Directory (
    ID INT CHECK (ID >= 1),
    name VARCHAR(256) NOT NULL,
    CONSTRAINT DirectoryPK PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS File (
    name VARCHAR(256) NOT NULL,
    directory INT,
    content TEXT,
    programmingLanguage TEXT,
    CONSTRAINT FilePK PRIMARY KEY (name, directory),
    CONSTRAINT FileDirectoryFK FOREIGN KEY (directory) REFERENCES Directory(ID),
    CONSTRAINT FileProgrammingLanguageFK FOREIGN KEY (programmingLanguage) REFERENCES ProgrammingLanguage(name)
);

CREATE TABLE IF NOT EXISTS ProgrammingLanguage (
    name TEXT NOT NULL,
    CONSTRAINT ProgrammingLanguagePK PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS FolderRelationship (
    parent INT,
    child INT, 
    CONSTRAINT FolderRelationshipPK PRIMARY KEY (parent, child),
    CONSTRAINT FolderRelationshipParentFK FOREIGN KEY (parent) REFERENCES Directory(ID),
    CONSTRAINT FolderRelationshipChildFK FOREIGN KEY (child) REFERENCES Directory(ID)
);