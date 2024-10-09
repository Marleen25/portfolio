---- Assignment 2 Part 1 Initial Database -------------------
/*
DROP TABLE A2P1_Departments CASCADE CONSTRAINTS;
DROP TABLE A2P1_PhoneTypes CASCADE CONSTRAINTS;
DROP TABLE A2P1_Employees CASCADE CONSTRAINTS;
DROP TABLE A2P1_EmployeePhoneNumbers CASCADE CONSTRAINTS;
DROP TABLE A2P1_BenefitTypes CASCADE CONSTRAINTS;
DROP TABLE A2P1_EmployeeBenefits CASCADE CONSTRAINTS;
DROP TABLE A2P1_Providers CASCADE CONSTRAINTS;
DROP TABLE A2P1_Claims CASCADE CONSTRAINTS;
*/

CREATE TABLE A2P1_Departments(
	DepartmentID 	NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	DepartmentName 	NVARCHAR2(150) NOT NULL,
	StreetAddress 	NVARCHAR2(100) NOT NULL,
	City 			NVARCHAR2(60) NOT NULL,
	Province 		NVARCHAR2(50) NOT NULL,
	PostalCode 		CHAR(6) NOT NULL,
	MaxWorkstations NUMBER(10) DEFAULT(1) NOT NULL,--DEFAULTS THE WORKSTAION TO 1 WHEN NULL
	CONSTRAINT PK_Department PRIMARY KEY (DepartmentID),
    --CREATES A UNIQUE CONSTRAINT FOR THE DEPARTMENT NAME
    CONSTRAINT UQ_DepartmentName UNIQUE (DepartmentName),
    -- Ensure that the number of maximum workstations is greater than 0
   CONSTRAINT CK_A2P1_Departments_MaxWorkstation CHECK (MaxWorkstations > 0)  
);

CREATE TABLE A2P1_PhoneTypes(
	PhoneTypeID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	PhoneType NVARCHAR2(50) NOT NULL,
	CONSTRAINT PK_PhoneTypes PRIMARY KEY (PhoneTypeID)
);
  
CREATE TABLE A2P1_Employees(
	EmployeeID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	FirstName NVARCHAR2(50) NOT NULL,
	MiddleName NVARCHAR2(50) NULL,
	LastName NVARCHAR2(50) NOT NULL,
	DateofBirth DATE NOT NULL,
	SIN char(9) NOT NULL,
	DefaultDepartmentID  NUMBER(10) NOT NULL,
    CurrentDepartmentID  NUMBER(10) NOT NULL,
	ReportsToEmployeeID NUMBER(10) NULL, 
	StreetAddress NVARCHAR2(100) NULL,
	City NVARCHAR2(60) NULL,
	Province NVARCHAR2(50) NULL,
	PostalCode CHAR(6) NULL,
	StartDate  DATE NOT NULL,
	-- Defines the BaseSalary column to store numeric values representing the base salary of employees, with a default value of 0 and disallows null values.
    BaseSalary NUMBER(18, 2) DEFAULT(0) NOT NULL,
-- 	BonusPercent NUMBER(3, 2) NOT NULL -- Best not to Store, as this Can be calculated from Employee data
	CONSTRAINT PK_Employee PRIMARY KEY (EmployeeID),
    -- CREATES A CONSTARINT UNIQUE ON SIN
    CONSTRAINT UQ_SIN UNIQUE (SIN),
    
	CONSTRAINT FK_Employee_Department_Default FOREIGN KEY (DefaultDepartmentID) REFERENCES A2P1_Departments ( DepartmentID ),
	CONSTRAINT FK_Employee_Department_Current FOREIGN KEY (CurrentDepartmentID) REFERENCES A2P1_Departments ( DepartmentID ),
	CONSTRAINT FK_Employee_ReportsTo FOREIGN KEY (ReportsToEmployeeID) REFERENCES A2P1_Employees ( EmployeeID )
    
);

CREATE TABLE A2P1_EmployeePhoneNumbers(
	EmployeePhoneNumberID NUMBER(10) GENERATED ALWAYS AS IDENTITY,
	EmployeeID NUMBER(10) NOT NULL, 
	PhoneTypeID NUMBER(10) NOT NULL, 
	PhoneNumber NVARCHAR2(14) NULL,
	CONSTRAINT PK_EmployeePhoneNumbers PRIMARY KEY (EmployeePhoneNumberID),
	CONSTRAINT FK_EmployeePhoneNumbers_Employee FOREIGN KEY(EmployeeID) REFERENCES A2P1_Employees ( EmployeeID ),
	CONSTRAINT FK_EmployeePhoneNumbers_PhoneTypes FOREIGN KEY(PhoneTypeID) REFERENCES A2P1_PhoneTypes (PhoneTypeID )
); 

CREATE TABLE A2P1_BenefitTypes(
	BenefitTypeID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	BenefitType NVARCHAR2(100) NOT NULL,
	BenefitCompanyName NVARCHAR2(100) NOT NULL,
    PolicyNumber INT NULL,
	CONSTRAINT PK_BenefitTypes PRIMARY KEY (BenefitTypeID),
    --Ensures that each policy number in the A2P1_BenefitTypes table is unique
    CONSTRAINT UK_A2P1_BenefitTypes_PolicyNumber UNIQUE (PolicyNumber)
);

CREATE TABLE A2P1_EmployeeBenefits(
	EmployeeBenefitID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	EmployeeId NUMBER(10) NOT NULL, 
	BenefitTypeID NUMBER(10) NOT NULL, 
    StartDate DATE NULL,
	CONSTRAINT PK_EmployeeBenefits PRIMARY KEY(EmployeeBenefitID), 
	CONSTRAINT FK_Employee FOREIGN KEY (EmployeeId) REFERENCES A2P1_Employees ( EmployeeID ),
	CONSTRAINT FK_Employee_BenefitTypes FOREIGN KEY (BenefitTypeID) REFERENCES A2P1_BenefitTypes ( BenefitTypeID )
);

CREATE TABLE A2P1_Providers (
	ProviderID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	ProviderName  NVARCHAR2(50) NOT NULL,
	ProviderAddress NVARCHAR2(60) NOT NULL,
	ProviderCity NVARCHAR2(50) NOT NULL,
	CONSTRAINT PK_Providers PRIMARY KEY (ProviderID) 
);

CREATE TABLE A2P1_Claims(
	ClaimID NUMBER(10) GENERATED ALWAYS AS IDENTITY, 
	ProviderID NUMBER(10) NOT NULL, 
    -- DEFAULTS THE CLAIM AMOUNT TO 0 WHEN NULL
    ClaimAmount NUMBER(18, 2) DEFAULT(0) NOT NULL,
    --Date when the service was performed. Default value is the current system date
	ServiceDate DATE DEFAULT SYSDATE NOT NULL,
	EmployeeBenefitID INT NULL, 
    -- Date when the claim was submitted. Default value is the current system date
	ClaimDate DATE DEFAULT SYSDATE NOT NULL,
	CONSTRAINT PK_Claims PRIMARY KEY (ClaimID), 
	CONSTRAINT FK_Provider FOREIGN KEY (ProviderID) REFERENCES A2P1_Providers ( ProviderID ),
	CONSTRAINT FK_Claims_EmployeeBenefits FOREIGN KEY (EmployeeBenefitID) REFERENCES A2P1_EmployeeBenefits ( EmployeeBenefitID )
);

/*The customer has told you that whenever an employee is added, their SIN number is used to uniquely identify that 
employee in the database. Lookups on SIN Number will need to be properly optimized and constrained*/
--



/*In testing, the customer found that a department’s maximum number of physical workstations would sometimes 
incorrectly be set to a negative number. Since this is invalid, they would like to prevent negative numbers from 
being added to the maximum workstations’ column. Testing also found that department records were frequently 
looked up by DepartmentName, which can be used to uniquely identify records. They would like these lookups 
optimized.*/



/*The customer has identified that dates in the system (Employees.DateOfBirth, Employee.StartDate, 
EmployeeBenefits.StartDate, Claims.ServiceDate, and Claims.ClaimDate) should never be a future date, so they 
must be equal to or less than the current datetime. When testing these tables the customer discovered that 
Benefits will often be uniquely identified by PolicyNumber. This lookup will need to be optimized.*/
-- This trigger ensures that the Date of Birth and Start Date for new employees cannot be set to a future date
CREATE OR REPLACE TRIGGER "TRIGGER_EMPLOYEES"
BEFORE INSERT ON A2P1_Employees
FOR EACH ROW 
BEGIN
   IF :NEW.DateofBirth > SYSDATE THEN 
      raise_application_error(-20001, 'Date Of Birth cannot be a future date');
    END IF;
  IF :NEW.StartDate > SYSDATE THEN 
     raise_application_error (-20001, 'Start Date cannot be a future date');
    END IF;
END;

-- This trigger ensures that the Start Date for new employee benefits cannot be set to a future date
CREATE OR REPLACE TRIGGER "TRIGGER_EMPLOYEEBENEFITS"
BEFORE INSERT ON A2P1_EmployeeBenefits
FOR EACH ROW 
BEGIN 
    IF :NEW.StartDate > SYSDATE THEN
    raise_application_error (-20001, 'Start Date cannot be a future date');
   END IF;
END;

-- This trigger ensures that the Service Date and Claim Date for new claims cannot be set to a future date
CREATE OR REPLACE TRIGGER "TRIGGER_CLAIMS"
BEFORE INSERT ON A2P1_Claims
FOR EACH ROW
BEGIN 
    IF :NEW.ServiceDate > SYSDATE THEN 
    raise_application_error (-20001, 'Service Date cannot be a future date');
   END IF;
  IF :NEW.ClaimDate > SYSDATE THEN 
  raise_application_error (-20001, 'Claim Date cannot be a future date');
  END IF;
END;  



/* A review of queries on the Employees table identified three queries that need to be optimized. The first query 
creates a sorted list of cities and postal codes. This list is sorted by city first, then by postal code. The second query 
looks up records by city only. The last query looks up records by postal code only.*/

-- This index is created on the City and PostalCode columns of the A2P1_Employees table to improve performance when querying based on these fields, particularly for operations involving filtering or sorting by city and postal code.
CREATE INDEX idx_city_postal ON A2P1_Employees (City, PostalCode);

-- This index is created on the City column of the A2P1_Employees table to improve performance when querying based on the city field. It helps speed up searches, filtering, and sorting operations that involve the city column
CREATE INDEX idx_City ON A2P1_Employees (City);

-- This index is created on the PostalCode column of the A2P1_Employees table to improve performance when querying based on the postal code field. It helps speed up searches, filtering, and sorting operations that involve the postal code column.
CREATE INDEX idx_PostalCode ON A2P1_Employees (PostalCode);

/* The customer has found that lookups will frequently be done in both directions across all foreign keys. They would 
like lookups by the parent and child columns optimized for all foreign keys. They would also like you to optimize 
lookups in both directions across the three junction tables */
-- This index is created on the DefaultDepartmentID column of the A2P1_Employees table to improve performance when querying based on the default department ID field. It helps speed up searches, filtering, and sorting operations that involve the default department ID column
CREATE INDEX idx_Employees_DefaultDepartmentID ON A2P1_Employees(DefaultDepartmentID);
-- This index is created on the CurrentDepartmentID column of the A2P1_Employees table to improve performance when querying based on the current department ID field. It helps speed up searches, filtering, and sorting operations that involve the current department ID column
CREATE INDEX idx_Employees_CurrentDepartmentID ON A2P1_Employees(CurrentDepartmentID);
-- This index is created on the ReportsToEmployeeID column of the A2P1_Employees table to improve performance when querying based on the reports-to employee ID field. It helps speed up searches, filtering, and sorting operations that involve the reports-to employee ID column
CREATE INDEX idx_Employees_ReportsToEmployeeID ON A2P1_Employees(ReportsToEmployeeID);

--This index is created on the EmployeeId column of the A2P1_EmployeeBenefits table to improve performance when querying based on the employee ID field. It helps speed up searches, filtering, and sorting operations that involve the employee ID column
CREATE INDEX idx_EmployeeBenefits_EmployeeId ON A2P1_EmployeeBenefits(EmployeeId);
-- This index is created on the BenefitTypeID column of the A2P1_EmployeeBenefits table to improve performance when querying based on the benefit type ID field. It helps speed up searches, filtering, and sorting operations that involve the benefit type ID column
CREATE INDEX idx_EmployeeBenefits_BenefitTypeID ON A2P1_EmployeeBenefits(BenefitTypeID);

-- This index is created on the ProviderID column of the A2P1_Claims table to improve performance when querying based on the provider ID field. It helps speed up searches, filtering, and sorting operations that involve the provider ID column
CREATE INDEX idx_Claims_ProviderID ON A2P1_Claims(ProviderID);
-- This index is created on the EmployeeBenefitID column of the A2P1_Claims table to improve performance when querying based on the employee benefit ID field. It helps speed up searches, filtering, and sorting operations that involve the employee benefit ID column
CREATE INDEX idx_Claims_EmployeeBenefitID ON A2P1_Claims(EmployeeBenefitID);

-- This index is created on the EmployeeID and PhoneTypeID columns of the A2P1_EmployeePhoneNumbers table to improve performance when querying based on the employee ID and phone type ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_EmployeePhoneNumbers_EmployeeID_PhoneTypeID ON A2P1_EmployeePhoneNumbers(EmployeeID, PhoneTypeID);
-- This index is created on the PhoneTypeID and EmployeeID columns of the A2P1_EmployeePhoneNumbers table to improve performance when querying based on the phone type ID and employee ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_EmployeePhoneNumbers_PhoneTypeID_EmployeeID ON A2P1_EmployeePhoneNumbers(PhoneTypeID, EmployeeID);

-- This index is created on the EmployeeId and BenefitTypeID columns of the A2P1_EmployeeBenefits table to improve performance when querying based on the employee ID and benefit type ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_EmployeeBenefits_EmployeeId_BenefitTypeID ON A2P1_EmployeeBenefits(EmployeeId, BenefitTypeID);
-- This index is created on the BenefitTypeID and EmployeeId columns of the A2P1_EmployeeBenefits table to improve performance when querying based on the benefit type ID and employee ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_EmployeeBenefits_BenefitTypeID_EmployeeId ON A2P1_EmployeeBenefits(BenefitTypeID, EmployeeId);

-- This index is created on the EmployeeBenefitID and ProviderID columns of the A2P1_Claims table to improve performance when querying based on the employee benefit ID and provider ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_Claims_EmployeeBenefitID_ProviderID ON A2P1_Claims(EmployeeBenefitID, ProviderID);
-- This index is created on the ProviderID and EmployeeBenefitID columns of the A2P1_Claims table to improve performance when querying based on the provider ID and employee benefit ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_Claims_ProviderID_EmployeeBenefitID ON A2P1_Claims(ProviderID, EmployeeBenefitID);

/* Covering indexes should be provided to quickly look up Employees by PhoneTypes, PhoneTypes by Employees, 
Employees by BenefitTypes, BenefitTypes by Employees, Providers by EmployeeBenefits, or EmployeeBenefits by 
Providers */
-- This index is created on the EmployeeID and PhoneTypeID columns of the A2P1_EmployeePhoneNumbers table to improve performance when querying based on the employee ID and phone type ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns.
CREATE INDEX idx_Employees_Phonetypes ON A2P1_EmployeePhoneNumbers(EmployeeID, PhoneTypeID);

-- This index is created on the PhoneTypeID and EmployeeID columns of the A2P1_EmployeePhoneNumbers table to improve performance when querying based on the phone type ID and employee ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_Phonetypes_Employees ON A2P1_EmployeePhoneNumbers(PhoneTypeID, EmployeeID);

-- This index is created on the EmployeeId and BenefitTypeID columns of the A2P1_EmployeeBenefits table to improve performance when querying based on the employee ID and benefit type ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_Employees_Benefittypes ON A2P1_EmployeeBenefits(EmployeeId, BenefitTypeID);

-- This index is created on the BenefitTypeID and EmployeeId columns of the A2P1_EmployeeBenefits table to improve performance when querying based on the benefit type ID and employee ID fields. It helps speed up searches, filtering, and sorting operations that involve these columns
CREATE INDEX idx_Benefittypes_Employees ON A2P1_EmployeeBenefits(BenefitTypeID, EmployeeId);

-- This index is created on the EmployeeBenefitID and ProviderID columns of the A2P1_Claims table to optimize performance when querying based on the employee benefit ID and provider ID fields. It enhances the speed of searches, filtering, and sorting operations involving these columns.
CREATE INDEX idx_Providers_Employeebenefits ON A2P1_Claims(EmployeeBenefitID, ProviderID);

-- This index is created on the ProviderID and EmployeeBenefitID columns of the A2P1_Claims table to optimize performance when querying based on the provider ID and employee benefit ID fields. It enhances the speed of searches, filtering, and sorting operations involving these columns.
CREATE INDEX idx_Employeebenefits_Provider ON A2P1_Claims(ProviderID, EmployeeBenefitID);






    
