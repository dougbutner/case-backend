-- 1. cases table
CREATE TABLE cases (
    case_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each case
    title VARCHAR(255) NOT NULL, -- Title of the case
    description TEXT NOT NULL, -- Description of the case
    request_damage_amount DECIMAL(15, 2) NOT NULL, -- Total amount of damages requested
    minimum_damage_amount DECIMAL(15, 2) NOT NULL, -- Minimum acceptable damage amount
    lawyer_fee DECIMAL(15, 2) NOT NULL, -- Minimum amount for the lawyer to take the case
    lawyer_id INT, -- Foreign key linking to the lawyer handling the case
    status ENUM('Open', 'Closed', 'In Progress', 'Under Review', 'Won', 'Lost', 'Settled') NOT NULL, -- Current status of the case
    winning_prediction_probability DECIMAL(5, 2), -- Expected probability of winning (optional)
    funding_amount_progress DECIMAL(5, 2) DEFAULT 0.00, -- Percentage of funding goal reached
    final_winning_amount DECIMAL(15, 2), -- Actual amount awarded if case is won
    FOREIGN KEY (lawyer_id) REFERENCES lawyers(lawyer_id) -- Foreign key constraint to lawyers
) ENGINE=InnoDB;

-- 2. lawyers table
CREATE TABLE lawyers (
    lawyer_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each lawyer
    is_case_lawyer BOOLEAN NOT NULL DEFAULT TRUE, -- Indicates if the lawyer is handling the case
    cases_won INT DEFAULT 0, -- Total number of cases won by the lawyer
    cases_lost INT DEFAULT 0 -- Total number of cases lost by the lawyer
) ENGINE=InnoDB;

-- 3. investors table
CREATE TABLE investors (
    investor_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each investor
    investor_kyc_id VARCHAR(255) NOT NULL, -- KYC (Know Your Customer) identifier
    investor_kyc_provider VARCHAR(255) NOT NULL -- KYC provider
) ENGINE=InnoDB;

-- 4. investments table
CREATE TABLE investments (
    investment_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each investment
    investor_id INT, -- Foreign key linking to the investors table
    case_id INT, -- Foreign key linking to the cases table
    wallet_address VARCHAR(255) NOT NULL, -- Investor's cryptocurrency wallet address
    amount_invested DECIMAL(15, 2) NOT NULL, -- Amount invested by the investor
    investment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the investment was made
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id), -- Foreign key constraint to investors
    FOREIGN KEY (case_id) REFERENCES cases(case_id) -- Foreign key constraint to cases
) ENGINE=InnoDB;

-- 5. case_damages table
CREATE TABLE case_damages (
    case_id INT PRIMARY KEY, -- Foreign key linking to the cases table
    distribution_to_winners DECIMAL(5, 2) DEFAULT 50.00, -- Percentage distributed to winners
    distribution_to_investors DECIMAL(5, 2) DEFAULT 25.00, -- Percentage distributed to investors
    distribution_to_project DECIMAL(5, 2) DEFAULT 25.00, -- Percentage distributed to the project
    distribution_to_lawyer DECIMAL(5, 2), -- Percentage distributed to the lawyer
    FOREIGN KEY (case_id) REFERENCES cases(case_id) -- Foreign key constraint to cases
) ENGINE=InnoDB;

-- 6. proofs table
CREATE TABLE proofs (
    proof_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each proof
    case_id INT, -- Foreign key linking to the cases table
    proof_text TEXT NOT NULL, -- Text field containing the proof details
    FOREIGN KEY (case_id) REFERENCES cases(case_id) -- Foreign key constraint to cases
) ENGINE=InnoDB;

-- 7. damages table
CREATE TABLE damages (
    damage_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each damage record
    case_id INT, -- Foreign key linking to the cases table
    damage_description TEXT NOT NULL, -- Description of the damages claimed
    damage_amount DECIMAL(15, 2) NOT NULL, -- Specific amount of damages being requested
    FOREIGN KEY (case_id) REFERENCES cases(case_id) -- Foreign key constraint to cases
) ENGINE=InnoDB;

-- 8. transactions table
CREATE TABLE transactions (
    transaction_id_internal INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each transaction
    case_id INT, -- Foreign key linking to the cases table
    payment_type ENUM('Investor Payment', 'Lawyer Fee', 'Project Payout') NOT NULL, -- Type of payment
    recipient_address VARCHAR(255) NOT NULL, -- Address receiving the payment (linked to investors)
    transaction_id_onchain VARCHAR(255) NOT NULL, -- Blockchain transaction hash for verification
    amount DECIMAL(15, 2) NOT NULL, -- Amount transferred in the transaction
    FOREIGN KEY (case_id) REFERENCES cases(case_id) -- Foreign key constraint to cases
) ENGINE=InnoDB;
